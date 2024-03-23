import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:loxia_annotations/loxia_annotations.dart';
import 'package:loxia_generators/helpers/types/class_config.dart';
import 'package:loxia_generators/helpers/types/column_config.dart';
import 'package:analyzer/src/dart/element/inheritance_manager3.dart' // ignore: implementation_imports
    show
        InheritanceManager3;
import 'package:source_gen/source_gen.dart';
import 'package:source_helper/source_helper.dart';

final _jsonKeyExpando = Expando<Map<ClassConfig, ColumnConfig>>();

const _columnChecker = TypeChecker.fromRuntime(Column);

String jsonLiteralAsDart(Object? value) {
  if (value == null) return 'null';

  if (value is String) return escapeDartString(value);

  if (value is double) {
    if (value.isNaN) {
      return 'double.nan';
    }

    if (value.isInfinite) {
      if (value.isNegative) {
        return 'double.negativeInfinity';
      }
      return 'double.infinity';
    }
  }

  if (value is bool || value is num) return value.toString();

  if (value is List) {
    final listItems = value.map(jsonLiteralAsDart).join(', ');
    return '[$listItems]';
  }

  if (value is Set) {
    final listItems = value.map(jsonLiteralAsDart).join(', ');
    return '{$listItems}';
  }

  if (value is Map) return jsonMapAsDart(value);

  throw StateError(
    'Should never get here – with ${value.runtimeType} - `$value`.',
  );
}

String jsonMapAsDart(Map value) {
  final buffer = StringBuffer()..write('{');

  var first = true;
  value.forEach((k, v) {
    if (first) {
      first = false;
    } else {
      buffer.writeln(',');
    }
    buffer
      ..write(escapeDartString(k as String))
      ..write(': ')
      ..write(jsonLiteralAsDart(v));
  });

  buffer.write('}');

  return buffer.toString();
}

ColumnConfig columnForField(FieldElement field, ClassConfig classAnnotation) =>
    (_jsonKeyExpando[field] ??= Map.identity())[classAnnotation] ??=
        _from(field, classAnnotation);

DartObject? _columnKeyAnnotation(FieldElement element) =>
    _columnChecker.firstAnnotationOf(element) ??
    (element.getter == null
        ? null
        : _columnChecker.firstAnnotationOf(element.getter!));

ConstantReader columnKeyAnnotation(FieldElement element) =>
    ConstantReader(_columnKeyAnnotation(element));

ColumnConfig _from(FieldElement element, ClassConfig classAnnotation) {
  // If an annotation exists on `element` the source is a 'real' field.
  // If the result is `null`, check the getter – it is a property.
  // TODO: setters: github.com/google/json_serializable.dart/issues/24
  final obj = columnKeyAnnotation(element);
  print('${obj.isNull} - ${obj.instanceOf(_columnChecker)}');
  
  if (obj.isNull) {
    return _populateColumn(
      classAnnotation,
      element,
    );
  }

  /// Returns a literal value for [dartObject] if possible, otherwise throws
  /// an [InvalidGenerationSourceError] using [typeInformation] to describe
  /// the unsupported type.
  Object? literalForObject(
    String fieldName,
    DartObject dartObject,
    Iterable<String> typeInformation,
  ) {
    if (dartObject.isNull) {
      return null;
    }

    final reader = ConstantReader(dartObject);

    String? badType;
    if (reader.isSymbol) {
      badType = 'Symbol';
    } else if (reader.isType) {
      badType = 'Type';
    } else if (dartObject.type is FunctionType) {
      // Function types at the "root" are already handled. If they occur
      // here, it's because the function is nested instead of a collection
      // literal, which is NOT supported!
      badType = 'Function';
    } else if (!reader.isLiteral) {
      badType = dartObject.type!.element?.name;
    }

    if (badType != null) {
      badType = typeInformation.followedBy([badType]).join(' > ');
      throw Exception(
        '`$fieldName` is `$badType`, it must be a literal.',
      );
    }

    if (reader.isDouble || reader.isInt || reader.isString || reader.isBool) {
      return reader.literalValue;
    }

    if (reader.isList) {
      return [
        for (var e in reader.listValue)
          literalForObject(fieldName, e, [
            ...typeInformation,
            'List',
          ])
      ];
    }

    if (reader.isSet) {
      return {
        for (var e in reader.setValue)
          literalForObject(fieldName, e, [
            ...typeInformation,
            'Set',
          ])
      };
    }

    if (reader.isMap) {
      final mapTypeInformation = [
        ...typeInformation,
        'Map',
      ];
      return reader.mapValue.map(
        (k, v) => MapEntry(
          literalForObject(fieldName, k!, mapTypeInformation),
          literalForObject(fieldName, v!, mapTypeInformation),
        ),
      );
    }

    badType = typeInformation.followedBy(['$dartObject']).join(' > ');

  }

  /// Returns a literal object representing the value of [fieldName] in [obj].
  ///
  /// If [mustBeEnum] is `true`, throws an [InvalidGenerationSourceError] if
  /// either the annotated field is not an `enum` or `List` or if the value in
  /// [fieldName] is not an `enum` value.
  String? createAnnotationValue(String fieldName, {bool mustBeEnum = false}) {
    final annotationValue = obj.read(fieldName);

    if (annotationValue.isNull) {
      return null;
    }

    final objectValue = annotationValue.objectValue;
    final annotationType = objectValue.type!;
    final defaultValueLiteral = literalForObject(fieldName, objectValue, []);
    if (defaultValueLiteral == null) {
      return null;
    }
    return jsonLiteralAsDart(defaultValueLiteral);
  }
  final defaultValue = createAnnotationValue('name');
  print(defaultValue);
  return _populateColumn(
    classAnnotation,
    element,
  );
}

ColumnConfig _populateColumn(
  ClassConfig classAnnotation,
  FieldElement element
) {

  return ColumnConfig();
}

bool _includeIfNull(
  bool? keyIncludeIfNull,
  bool? keyDisallowNullValue,
  bool classIncludeIfNull,
) {
  if (keyDisallowNullValue == true) {
    assert(keyIncludeIfNull != true);
    return false;
  }
  return keyIncludeIfNull ?? classIncludeIfNull;
}

bool _interfaceTypesEqual(DartType a, DartType b) {
  if (a is InterfaceType && b is InterfaceType) {
    // Handle nullability case. Pretty sure this is fine for enums.
    return a.element == b.element;
  }
  return a == b;
}

List<FieldElement> createSortedFieldSet(ClassElement element) {
  // Get all of the fields that need to be assigned
  // TODO: support overriding the field set with an annotation option
  final elementInstanceFields = Map.fromEntries(
      element.fields.where((e) => !e.isStatic).map((e) => MapEntry(e.name, e)));

  final inheritedFields = <String, FieldElement>{};
  final manager = InheritanceManager3();
  print("VALUES: ${manager.getInheritedConcreteMap2(element).values}");
  for (final v in manager.getInheritedConcreteMap2(element).values) {
    assert(v is! FieldElement);
    print('Field: $v');
    if (v is PropertyAccessorElement && v.isGetter) {
      assert(v.variable is FieldElement);
      final variable = v.variable as FieldElement;
      assert(!inheritedFields.containsKey(variable.name));
      inheritedFields[variable.name] = variable;
    }
  }

  // Get the list of all fields for `element`
  final allFields =
      elementInstanceFields.keys.toSet().union(inheritedFields.keys.toSet());
  print(allFields);
  final fields = allFields
      .map((e) => elementInstanceFields[e] ?? inheritedFields[e]!)
      .toList();

  return fields.toList(growable: false);
}

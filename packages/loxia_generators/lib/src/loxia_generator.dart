import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:loxia_annotations/loxia_annotations.dart';
import 'package:loxia_generators/src/helpers/values_helper.dart';
import 'package:source_gen/source_gen.dart';
import 'package:source_helper/source_helper.dart';

import 'entity/information.dart';

const _columnChecker = TypeChecker.fromRuntime(Column);

const _relationChecker = TypeChecker.fromRuntime(Relation);

class LoxiaGenerator extends GeneratorForAnnotation<EntityMeta> {
  final Map<String, dynamic> options;

  const LoxiaGenerator(this.options);

  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    final buffer = StringBuffer();
    if (element is! ClassElement) {
      throw Exception('The @Entity annotation can only be used on classes.');
    }
    if (!element.fields
        .any((element) => _columnChecker.hasAnnotationOfExact(element))) {
      throw Exception(
          'The entity class must have at least one field annotated with @Column.');
    }
    final List<ColumnInformation> columns = [];
    final List<RelationInformation> relations = [];
    final columnHelper = ColumnHelper();
    if (element.fields.any((element) => element.isLate)) {
      throw Exception('All fields must be non-late.');
    }
    for (var f in element.fields) {
      if (_columnChecker.hasAnnotationOf(f)) {
        if (!f.isStatic) {
          columns.add(getColumn(f, columnHelper));
        }
      }
      if (_relationChecker.hasAnnotationOf(f)) {
        final relation = _relationChecker.firstAnnotationOf(f);
        final relationType = columnHelper.getRelationType(relation!);
        final relationEntity = columnHelper.getRelationEntity(f.type);
        if (!f.type.isDartCoreIterable && !f.type.isDartCoreList) {
          if (!f.type.isNullableType) {
            throw Exception('Relation fields must be nullable.');
          }
        }
        relations.add(RelationInformation(
            column: f.name,
            entity: element.name,
            inverseEntity: relationEntity,
            type: relationType,
            referenceType: f.type));
      }
    }
    buffer.writeln(_generateSchema(element, annotation, columns, relations));
    buffer.writeln(_generatePartialEntity(element));
    buffer.writeln(_generateGeneratedEntity(element, columns, relations));
    return buffer.toString();
  }

  ColumnInformation getColumn(FieldElement f, ColumnHelper columnHelper) {
    final column = _columnChecker.firstAnnotationOf(f);
    final name = column?.getField('name')?.toStringValue() ?? f.name;
    final defaultValue = columnHelper.getDefaultValue(
      column?.getField('defaultValue'),
    );
    final type = f.type.getDisplayString(withNullability: false);
    final isNullable = f.type.isNullableType;
    if (column?.type?.getDisplayString(withNullability: false) ==
        'PrimaryKey') {
      if (isNullable) {
        throw Exception('Primary key fields cannot be nullable.');
      }
      return ColumnInformation(
          name: name,
          field: f.name,
          type: type,
          explicitType: column?.getField('explicitType')?.toStringValue(),
          nullable: isNullable,
          primaryKey: true,
          autoIncrement:
              column?.getField('autoIncrement')?.toBoolValue() ?? false,
          uuid: column?.getField('uuid')?.toBoolValue() ?? false);
    }
    final isUnique = column?.getField('unique')?.toBoolValue() ?? false;
    return ColumnInformation(
        name: name,
        field: f.name,
        type: type,
        explicitType: column?.getField('explicitType')?.toStringValue(),
        nullable: isNullable,
        defaultValue: defaultValue,
        unique: isUnique);
  }

  String _generateSchema(
      Element element, ConstantReader annotation, List<ColumnInformation> columns, List<RelationInformation> relations
  ){
    final buffer = StringBuffer();
        final schemaName = annotation.read('schema').literalValue as String?;
    buffer.writeln('''
        final generatedSchema = Schema(
          ${schemaName != null ? 'name: \'$schemaName\',' : ''}
          table: Table(
            name: '${annotation.read('table').literalValue as String? ?? element.name!.toLowerCase()}',
      ''');
    if (columns.isNotEmpty) {
      buffer.writeln("columns: [");
      for (var column in columns) {
        buffer.writeln('''ColumnMetadata(
            name: '${column.name}',
            type: '${column.type}',
            explicitType: ${column.explicitType},
            nullable: ${column.nullable},
            primaryKey: ${column.primaryKey},
            unique: ${column.unique},
            defaultValue: ${column.defaultValue},
            ${column.autoIncrement ? 'autoIncrement: true,' : ''}
            ${column.uuid ? 'uuid: true,' : ''}
            ${column.length.isNotEmpty ? 'length: \'${column.length}\',' : ''}
            ${column.width != null ? 'width: ${column.width},' : ''}
            ${column.charset != null ? 'charset: \'${column.charset}\',' : ''}
          ),''');
      }
      buffer.writeln("],");
    }
    if (relations.isNotEmpty) {
      buffer.writeln("relations: [");
      for (var relation in relations) {
        buffer.writeln('''RelationMetadata(
            column: '${relation.column}',
            entity: ${relation.inverseEntity}Entity,
            inverseEntity: ${relation.entity}Entity,
            type: ${relation.type},
          ),''');
      }
      buffer.writeln("],");
    }

    buffer.writeln('''
          ),
        );
      ''');
    return buffer.toString();
  }

  String _generateGeneratedEntity(
    Element element, List<ColumnInformation> columns, List<RelationInformation> relations
  ) {
    final columnHelper = ColumnHelper();
    final buffer = StringBuffer();
    buffer.writeln('''class ${element.name}Entity extends GeneratedEntity {
        
        @override
        Type get entityCls => ${element.name};

      ''');
    buffer.writeln('''
        @override
        final Schema schema = generatedSchema;

        @override
        final PartialEntity partialEntity = Partial${element.name}();
      ''');

    buffer.writeln('''
        @override
        ${element.name} from(Map<String, dynamic> map) {
          return ${element.name}(
            ${columns.where((element) => element.relationEntity == null).map((e) => '${e.field}: map.containsKey("${e.name}") ? map[\'${e.name}\'] : ${!e.nullable ? columnHelper.getValueOrDefault(e) ?? columnHelper.getFallbackValue(e.type) : null}').join(',\n')},\n
            ${relations.map((e) => '${e.column}: map.containsKey(\'${e.column}\') && map[\'${e.column}\'] is ${e.referenceType!.isDartCoreIterable || e.referenceType!.isDartCoreList ? 'List<Map<String, dynamic>> ? map[\'${e.column}\'].map(${e.entity}.entity.from) : []' : 'Map<String, dynamic> ? ${e.inverseEntity}.entity.from(map[\'${e.column}\']) : null'}').join(',\n')}
          ); 
        }
      ''');

    buffer.writeln('\n');

    buffer.writeln('''
        @override
        Map<String, dynamic> to(${element.name} entity) {
          return {
            ${columns.map((e) => '\'${e.name}\': entity.${e.field}').join(',\n')},\n
            ${relations.map((e) => '\'${e.column}\': ${e.referenceType!.isDartCoreIterable || e.referenceType!.isDartCoreList ? 'entity.${e.column}.map(${e.inverseEntity}.entity.to).toList()' : 'entity.${e.column} != null ? ${e.inverseEntity}.entity.to(entity.${e.column}!) : null'}').join(',\n')}
          }..removeWhere((key, value) => value == null);
        }
      ''');

    buffer.writeln('\n');
    buffer.writeln('}');
    return buffer.toString();
  }

  String _generatePartialEntity(
    ClassElement element
  ){
    final buffer = StringBuffer();

    final fields = element.fields;
    final constructor = element.constructors.where((element) => element.isGenerative).firstOrNull;
    if(constructor == null) {
      throw Exception('The ${element.name} entity class must have a generative constructor');
    }
    final nonStaticFields = fields.where((element) => !element.isStatic);
    final requiredFields = nonStaticFields.where((element) => !element.type.isNullableType || element.isFinal).map((e) => e.name);
    final positionalParameters = constructor.parameters.where((element) => element.isPositional).map((e) => e.name);
    final requiredNamedParameters = constructor.parameters.where((element) => element.isRequiredNamed).map((e) => e.name);
    final optionalNamedParameters = constructor.parameters.where((element) => element.isOptionalNamed);
    final optionalPositionalParameters = constructor.parameters.where((element) => element.isOptionalPositional).map((e) => e.name);
    final namedParameters = StringBuffer();
    if(requiredNamedParameters.isNotEmpty){
      namedParameters.write(requiredNamedParameters.map((e) => '$e: $e!').join(','));
      namedParameters.write(',');
    }
    if(optionalNamedParameters.isNotEmpty){
      namedParameters.write(optionalNamedParameters.map((e) => '${e.name}: ${e.name}${e.hasDefaultValue ? ' ?? ${e.defaultValueCode}' : ''}').join(','));
    }
    buffer.writeln(
      '''class Partial${element.name} extends PartialEntity {

        ${
          nonStaticFields.map((e) => 
            '${e.type.getDisplayString(withNullability: false)}? ${e.name};'
          ).join('\n')
        }

        @override
        bool isPartial() {
          return ${requiredFields.map((e) => '$e == null').join(' || ')};
        }

        @override
        Map<String, dynamic> to(Partial${element.name} entity) {
          return {
            ${nonStaticFields.map((e) => '\'${e.name}\': entity.${e.name}').join(',\n')}
          };
        }

        @override
        Partial${element.name} from(Map<String, dynamic> values) {
          return Partial${element.name}(
            ${nonStaticFields.map((e) => '${e.name}: values.containsKey(\'${e.name}\') ? values[\'${e.name}\'] : null').join(',\n')}
          );
        }

        Partial${element.name}({
          ${nonStaticFields.map((e) => 'this.${e.name},').join('\n')}
        });

        @override
        ${element.name} toEntity() {
          if(isPartial()) {
            throw Exception('Cannot convert partial entity to entity');
          }
          return ${element.name}(
            ${
              positionalParameters.map((e) => 
                'this.$e'
              ).join(',\n')
            }
            ${positionalParameters.isNotEmpty ? ',' : ''}
            ${
              optionalPositionalParameters.isNotEmpty 
              ? '[${optionalPositionalParameters.map((e) => 
                  'this.$e'
                ).join(',\n')}]'
              : ''
            }
            ${optionalPositionalParameters.isNotEmpty ? ',' : ''}
            ${
              namedParameters.isNotEmpty 
              ? '$namedParameters'
              : ''
            }
          );
        }

      }
      '''
    );
    return buffer.toString();
  }

}

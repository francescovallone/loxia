import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:loxia_annotations/loxia_annotations.dart';
import 'package:loxia_generators/src/helpers/values_helper.dart';
import 'package:source_gen/source_gen.dart';
import 'package:source_helper/source_helper.dart';

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
    final schemaName = annotation.read('schema').literalValue as String?;
    buffer.writeln('''
        final generatedSchema = Schema(
          ${schemaName != null ? 'name: \'$schemaName\',' : ''}
          table: Table(
            name: '${annotation.read('table').literalValue as String? ?? element.name.toLowerCase()}',
      ''');
    final List<ColumnInformation> columns = [];
    final List<RelationInformation> relations = [];
    final columnHelper = ColumnHelper();
    if (element.fields.any((element) => element.isFinal || element.isLate)) {
      throw Exception('All fields must be mutable, non-static and non-late.');
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
        // buffer.writeln(
        //   '''FieldSchema(
        //     name: '${f.name}',
        //     type: 'String',
        //     nullable: false,
        //     unique: false,
        //     relationType: $relationType,
        //     relationEntity: $relationEntity,
        //   ),
        //   '''
        // );
        // columns.add(ColumnInformation(
        //   name: f.name,
        //   type: 'String',
        //   nullable: false,
        //   relationEntity: f.type
        // ));
      }
    }
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
    // final List<FieldInformation> fieldNames = [];
    // final columnHelper = ColumnHelper();
    // if(element.fields.any((element) => element.isFinal)){
    //   throw Exception('All fields must be mutable.');
    // }
    // for (var f in (element).fields) {
    //   if (_columnChecker.hasAnnotationOf(f)) {
    //     buffer.writeln(getColumn(f, columnHelper, fieldNames));
    //   }
    //   if(_relationChecker.hasAnnotationOf(f)){
    //     final relation = _relationChecker.firstAnnotationOf(f);
    //     final relationType = columnHelper.getRelationType(relation!);
    //     final relationEntity = columnHelper.getRelationEntity(f.type);
    //     buffer.writeln(
    //       '''FieldSchema(
    //         name: '${f.name}',
    //         type: 'String',
    //         nullable: false,
    //         unique: false,
    //         relationType: $relationType,
    //         relationEntity: $relationEntity,
    //       ),
    //       '''
    //     );
    //     fieldNames.add(FieldInformation(name: f.name, field: f.name, defaultValue: [], isNullable: false, relationEntity: f.type));
    //   }
    // }

    buffer.writeln('''
          ),
        );
      ''');
    buffer.writeln(''' class ${element.name}Entity extends GeneratedEntity {
        
        @override
        Type get entityCls => ${element.name};

      ''');
    buffer.writeln('''
        @override
        final Schema schema = generatedSchema;
      ''');
    // // GeneratorHelper helper = GeneratorHelper(element as ClassElement);

    // buffer.writeln('\n');

    buffer.writeln('''
        @override
        ${element.name} from(Map<String, dynamic> map) {
          return ${element.name}(
            ${columns.where((element) => element.relationEntity == null).map((e) => '${e.field}: map.containsKey("${e.name}") ? map[\'${e.name}\'] : ${!e.nullable ? e.defaultValue ?? columnHelper.getFallbackValue(e.type) : null}').join(',\n')},\n
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
          };
        }
      ''');

    buffer.writeln('\n');
    buffer.writeln('}');
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
}

class ColumnInformation {
  final String name;
  final String field;
  final String type;
  final dynamic defaultValue;
  final String? explicitType;
  final bool nullable;
  final bool primaryKey;
  final dynamic relationEntity;
  final bool autoIncrement;
  final bool uuid;
  final bool unique;
  final String length;
  final int? width;
  final String? charset;

  ColumnInformation({
    required this.name,
    required this.field,
    required this.type,
    this.explicitType,
    this.defaultValue,
    this.length = '',
    this.width,
    this.nullable = false,
    this.unique = false,
    this.primaryKey = false,
    this.relationEntity,
    this.autoIncrement = false,
    this.uuid = false,
    this.charset,
  }) : assert(autoIncrement == false || uuid == false,
            'autoIncrement and uuid cannot be true at the same time');
}

class RelationInformation {
  final String entity;
  final String inverseEntity;
  final String column;
  final String? referenceColumn;
  final String type;
  final dynamic referenceType;

  RelationInformation({
    required this.column,
    this.entity = '',
    this.inverseEntity = '',
    this.referenceColumn,
    this.type = 'none',
    this.referenceType,
  });
}

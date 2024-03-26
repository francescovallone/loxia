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
  generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) {
    final buffer = StringBuffer();
    if(element is! ClassElement) {
      throw Exception('The @Entity annotation can only be used on classes.');
    }
    buffer.writeln(
      ''' class ${element.name}Entity extends GeneratedEntity {
        @override
        final Table table = Table('${(annotation.read('table').literalValue as String?) ?? element.name.toLowerCase()}');

        @override
        final Type entityCls = ${element.name};

        factory ${element.name}Entity() => _instance;

        ${element.name}Entity._();

        static final ${element.name}Entity _instance = ${element.name}Entity._();
      '''
    );
    if(!element.fields.any((element) => _columnChecker.hasAnnotationOfExact(element))){
      throw Exception('The entity class must have at least one field annotated with @Column.');
    }
    buffer.writeln(
      '''
        @override
        final EntitySchema schema = EntitySchema([
      '''
    );
    // GeneratorHelper helper = GeneratorHelper(element as ClassElement);

    final List<({String name, String field, dynamic defaultValue, bool isNullable, dynamic relationEntity })> fieldNames = [];
    final columnHelper = ColumnHelper();
    for (var f in (element).fields) {
      if (_columnChecker.hasAnnotationOf(f)) {
        final column = _columnChecker.firstAnnotationOf(f);
        print(column);
        final name = column?.getField('name')?.toStringValue() ?? f.name;
        final defaultValue = columnHelper.getDefaultValue(
          column?.getField('defaultValue'),
        );
        final type = f.type.getDisplayString(withNullability: false);
        final isNullable = f.type.isNullableType;
        fieldNames.add((name: name, field: f.name, defaultValue: defaultValue, isNullable: isNullable, relationEntity: null));
        if(column?.type?.getDisplayString(withNullability: false) == 'PrimaryKey'){
          if(isNullable){
            throw Exception('Primary key fields cannot be nullable.');
          }
          buffer.writeln(
            '''FieldSchema(
              name: '$name',
              type: '$type',
              nullable: $isNullable,
              primaryKey: true,
              autoIncrement: ${(column?.getField('autoIncrement')?.toBoolValue() ?? false)},
              uuid: ${(column?.getField('uuid')?.toBoolValue() ?? false)},
            ),
            '''
          );
          continue;
        }
        final isUnique = column?.getField('unique')?.toBoolValue() ?? false;
        buffer.writeln(
          '''FieldSchema(
            name: '$name',
            type: '$type',
            nullable: $isNullable,
            unique: $isUnique,
            ${defaultValue == null && !isNullable ? '' : 'defaultValue: $defaultValue,'}
          ),
          '''
        );
      }
      if(_relationChecker.hasAnnotationOf(f)){
        final relation = _relationChecker.firstAnnotationOf(f);
        print(relation);
        final relationType = columnHelper.getRelationType(relation!);
        final relationEntity = columnHelper.getRelationEntity(f.type);
        print(relationEntity);
        print(relation.getField('hasForeignKey'));
        print(relation.toStringValue());
        buffer.writeln(
          '''FieldSchema(
            name: '${f.name}',
            type: 'String',
            nullable: false,
            unique: false,
            relationType: $relationType,
            relationEntity: $relationEntity,
          ),
          '''
        );
        fieldNames.add((name: f.name, field: f.name, defaultValue: [], isNullable: false, relationEntity: f.type));
      }
    }
    
    buffer.writeln(']);');

    buffer.writeln('\n');

    buffer.writeln(
      '''
        @override
        ${element.name} from(Map<String, dynamic> map) {
          return ${element.name}(
            ${fieldNames.where((element) => element.relationEntity == null).map((e) => '${e.field}: map.containsKey("${e.name}") ? map[\'${e.name}\'] : ${
              !e.isNullable ? '${e.defaultValue ?? "''"}' : e.defaultValue 
            }').join(',\n')},\n
            ${fieldNames.where((element) => element.relationEntity != null).map((e) => '${e.field}: ${
              e.relationEntity!.isDartCoreIterable || e.relationEntity!.isDartCoreList 
                ? 'map[\'${e.name}\'].map(${columnHelper.getRelationEntity(e.relationEntity!)}.entity.from)'
                : '${e.relationEntity}.entity.from(map[\'${e.name}\'])'
            }').join(',\n')}
          ); 
        }
      '''
    );

    buffer.writeln('\n');

    buffer.writeln(
      '''
        @override
        Map<String, dynamic> to(${element.name} entity) {
          return {
            ${fieldNames.map((e) => '\'${e.name}\': entity.${e.field}').join(',\n')}
          };
        }
      '''
    );

    buffer.writeln('\n');
    buffer.writeln('}');
    // final list = helper.generate();
    // print(list);

    return buffer.toString();
  }
}
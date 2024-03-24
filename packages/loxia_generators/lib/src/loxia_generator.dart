import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:loxia_annotations/loxia_annotations.dart';
import 'package:source_gen/source_gen.dart';
import 'package:source_helper/source_helper.dart';
const _columnChecker = TypeChecker.fromRuntime(Column);

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
        final String table = '${(annotation.read('table').literalValue as String?) ?? element.name.toLowerCase()}';

        @override
        final Type entityCls = ${element.name};
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

    final List<({String name, String field})> fieldNames = [];
    int primaryKeyCount = 0;
    for (var f in (element).fields) {
      if (_columnChecker.hasAnnotationOf(f)) {
        final column = _columnChecker.firstAnnotationOf(f);
        final name = column?.getField('name')?.toStringValue() ?? f.name;
        fieldNames.add((name: name, field: f.name));
        final type = f.type.getDisplayString(withNullability: false);
        final isNullable = f.type.isNullableType;
        if(column?.type?.getDisplayString(withNullability: false) == 'PrimaryKey'){
          if(primaryKeyCount > 0){
            throw Exception('Only one primary key field is allowed.');
          }
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
          primaryKeyCount++;
          continue;
        }
        buffer.writeln(
          '''FieldSchema(
            name: '$name',
            type: '$type',
            nullable: $isNullable,
          ),
          '''
        );
      }
    }
    buffer.writeln(']);');

    buffer.writeln('\n');

    buffer.writeln(
      '''
        @override
        ${element.name} from(Map<String, dynamic> map) {
          return ${element.name}(
            ${fieldNames.map((e) => '${e.field}: map.containsKey("${e.name}") ? map[\'${e.name}\'] : ""').join(',\n')}
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
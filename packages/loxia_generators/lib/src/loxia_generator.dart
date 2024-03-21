import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/visitor.dart';
import 'package:build/build.dart';
import 'package:loxia_annotations/loxia_annotations.dart';
import 'package:source_gen/source_gen.dart';

class LoxiaGenerator extends GeneratorForAnnotation<Entity> {

  final Map<String, dynamic> options;

  const LoxiaGenerator(this.options);

  @override
  generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) {
        final buffer = StringBuffer();
    buffer.writeln(
      ''' class ${element.name}Entity {
        final String table = '${(annotation.read('table').literalValue as String?) ?? element.name!.toLowerCase()}';
      }'''
    );

    return buffer.toString();
  }
}
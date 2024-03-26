import 'package:loxia/loxia.dart';
import 'package:loxia/src/entity/table.dart';

abstract class Entity {

  static dynamic get entity => throw UnimplementedError();

}

abstract class GeneratedEntity {

  Table get table;

  EntitySchema get schema;

  Type get entityCls;

  Entity from(Map<String, dynamic> values);

  Map<String, dynamic> to(covariant Entity entity);

}
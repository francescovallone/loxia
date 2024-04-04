import 'entity_schema.dart';

abstract class Entity {
  static dynamic get entity => throw UnimplementedError();
}

abstract class GeneratedEntity {
  Schema get schema;

  Type get entityCls;

  Entity from(Map<String, dynamic> values);

  Map<String, dynamic> to(covariant Entity entity);
}

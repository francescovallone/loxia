import 'package:loxia/loxia.dart';

import 'entity_schema.dart';

abstract class Entity {
  static dynamic get entity => throw UnimplementedError();
}

abstract class GeneratedEntity {
  Schema get schema;

  PartialEntity get partialEntity;

  Type get entityCls;

  Entity from(Map<String, dynamic> values);

  Map<String, dynamic> to(covariant Entity entity);
}

abstract class PartialEntity {

  Map<String, dynamic> to(covariant PartialEntity entity);

  PartialEntity from(Map<String, dynamic> values);

  bool isPartial();

  Entity toEntity();

}
import '../entity/entity.dart';
import '../enums/relation_type_enum.dart';

class RelationMetadata {
  final GeneratedEntity entity;
  final GeneratedEntity inverseEntity;
  final
  final RelationType type;

  const RelationMetadata({
    required this.column,
    required this.entity,
    this.referenceColumn = 'id',
    this.type = RelationType.oneToOne,
  });
}
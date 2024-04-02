
import 'package:loxia/src/enums/relation_type_enum.dart';

class RelationMetadata {
  final Type entity;
  final Type inverseEntity;
  final String column;
  final String? referenceColumn;
  final RelationType type;

  const RelationMetadata({
    required this.column,
    required this.entity,
    required this.inverseEntity,
    this.referenceColumn,
    this.type = RelationType.oneToOne,
  });
}
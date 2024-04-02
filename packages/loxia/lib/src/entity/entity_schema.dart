import 'package:loxia/src/entity/table.dart';

import '../enums/relation_type_enum.dart';

class Schema {

  final String? name;

  final Table table;

  Schema({
    required this.table,
    this.name,
  });

  @override
  String toString() {
    return 'Schema{name: $name}';
  }
}

class FieldSchema {
  final String name;
  final String type;
  final bool primaryKey;
  final bool autoIncrement;
  final bool uuid;
  final bool nullable;
  final String? explicitType;
  final dynamic defaultValue;
  final bool unique;
  final bool hasForeignKey;
  final RelationType relationType;
  final Type? relationEntity;

  const FieldSchema({
    required this.name,
    required this.type,
    this.primaryKey = false,
    this.autoIncrement = false,
    this.uuid = false,
    this.nullable = false,
    this.explicitType,
    this.unique = false,
    this.defaultValue,
    this.hasForeignKey = false,
    this.relationType = RelationType.none,
    this.relationEntity,
  });

  @override
  String toString() {
    return 'FieldSchema{name: $name, type: $type, isPrimaryKey: $primaryKey, isAutoIncrement: $autoIncrement, isUuid: $uuid, isNullable: $nullable}';
  }
}
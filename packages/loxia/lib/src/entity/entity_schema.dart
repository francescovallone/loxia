import 'package:loxia/src/entity/entity.dart';

import '../enums/relation_type_enum.dart';

class EntitySchema {

  final List<FieldSchema> _fields;

  List<FieldSchema> get fields => _fields;

  List<FieldSchema> get primaryKeys => _fields.where((f) => f.primaryKey).toList();

  EntitySchema(this._fields);

  FieldSchema? getField(String name) {
    return _fields.where((f) => f.name == name).firstOrNull;
  }

  @override
  String toString() {
    return 'EntitySchema{fields: $_fields}';
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

class ColumnMetadata {

  final String name;
  final String type;
  final bool nullable;
  final bool unique;
  final dynamic defaultValue;

  const ColumnMetadata({
    required this.name,
    required this.type,
    this.nullable = false,
    this.unique = false,
    this.defaultValue,
  });

}


class RelationMetadata {

  final String referenceColumn;
  final String column;
  final GeneratedEntity? entity;
  final RelationType type;

  const RelationMetadata({
    required this.column,
    required this.entity,
    this.referenceColumn = 'id',
    this.type = RelationType.oneToOne,
  });

}

class PrimaryKeyMetadata{

  final bool autoIncrement;
  final bool uuid;
  final String name;
  final String type;

  const PrimaryKeyMetadata({
    this.autoIncrement = false,
    this.uuid = false,
    required this.name,
    required this.type
  }): assert(
    autoIncrement == false || uuid == false,
    'autoIncrement and uuid cannot be true at the same time'
  ), assert(
    type == 'String' || type == 'int',
    'Primary key type must be either String or int'
  ), assert(
    uuid == true && type == 'int',
    'Primary key type must be String if uuid is true'
  );

}
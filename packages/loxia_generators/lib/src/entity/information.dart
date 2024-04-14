class ColumnInformation {
  final String name;
  final String field;
  final String type;
  final dynamic defaultValue;
  final String? explicitType;
  final bool nullable;
  final bool primaryKey;
  final dynamic relationEntity;
  final bool autoIncrement;
  final bool uuid;
  final bool unique;
  final String length;
  final int? width;
  final String? charset;

  ColumnInformation({
    required this.name,
    required this.field,
    required this.type,
    this.explicitType,
    this.defaultValue,
    this.length = '',
    this.width,
    this.nullable = false,
    this.unique = false,
    this.primaryKey = false,
    this.relationEntity,
    this.autoIncrement = false,
    this.uuid = false,
    this.charset,
  }) : assert(autoIncrement == false || uuid == false,
            'autoIncrement and uuid cannot be true at the same time');
}

class RelationInformation {
  final String entity;
  final String inverseEntity;
  final String column;
  final String? referenceColumn;
  final String type;
  final dynamic referenceType;

  RelationInformation({
    required this.column,
    this.entity = '',
    this.inverseEntity = '',
    this.referenceColumn,
    this.type = 'none',
    this.referenceType,
  });
}
class EntitySchema {

  final List<FieldSchema> _fields;

  List<FieldSchema> get fields => _fields;

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

  const FieldSchema({
    required this.name,
    required this.type,
    this.primaryKey = false,
    this.autoIncrement = false,
    this.uuid = false,
    this.nullable = false,
  });

  @override
  String toString() {
    return 'FieldSchema{name: $name, type: $type, isPrimaryKey: $primaryKey, isAutoIncrement: $autoIncrement, isUuid: $uuid, isNullable: $nullable}';
  }

}
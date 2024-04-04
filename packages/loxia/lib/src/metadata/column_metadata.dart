import 'relation_metadata.dart';

class ColumnMetadata {
  final RelationMetadata? relation;

  final String name;

  final String type;

  final String? explicitType;

  final String length;

  final int? width;

  final String? charset;

  final bool primaryKey;

  final bool autoIncrement;

  final bool uuid;

  final bool nullable;

  final bool unique;

  final dynamic defaultValue;

  final ColumnMetadata? referenceColumn;

  String get propertyPath {
    final path = StringBuffer();
    path.write(name);
    if (referenceColumn?.name != name) {
      path.write('.${referenceColumn?.name}');
    }
    return path.toString();
  }

  String get databasePath {
    final path = StringBuffer();
    path.write(databaseName);
    if (referenceColumn?.databaseName != databaseName) {
      path.write('.${referenceColumn?.databaseName}');
    }
    return path.toString();
  }

  String databaseName = '';

  String get aliasName {
    return propertyPath.replaceAll('.', '_');
  }

  ColumnMetadata({
    required this.name,
    required this.type,
    this.primaryKey = false,
    this.autoIncrement = false,
    this.relation,
    this.explicitType,
    this.referenceColumn,
    this.length = '',
    this.width,
    this.nullable = false,
    this.unique = false,
    this.defaultValue,
    this.charset,
    this.uuid = false,
  });
}

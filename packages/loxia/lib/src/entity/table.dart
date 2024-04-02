import '../metadata/column_metadata.dart';

class Table {
  final String name;

  final List<ColumnMetadata> columns;

  // final List<PrimaryKeyMetadata> primaryKeys = [];

  // final List<RelationMetadata> foreignKeys = [];

  Table({
    required this.name,
    this.columns = const [],
  });
}

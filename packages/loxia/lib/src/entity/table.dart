import '../metadata/column_metadata.dart';
import '../metadata/relation_metadata.dart';

class Table {
  final String name;

  final List<ColumnMetadata> columns;

  // final List<PrimaryKeyMetadata> primaryKeys = [];

  final List<RelationMetadata> relations;

  const Table({
    required this.name,
    this.columns = const [],
    this.relations = const [],
  });
}

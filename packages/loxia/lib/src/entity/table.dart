import 'package:loxia/src/entity/entity_schema.dart';

class Table {
  final String name;

  final List<ColumnMetadata> columns = [];

  final List<PrimaryKeyMetadata> primaryKeys = [];

  final List<RelationMetadata> foreignKeys = [];

  Table(
    this.name,
  );
}

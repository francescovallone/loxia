import 'package:loxia/loxia.dart';

import '../queries/count_options.dart';
import '../transformers/transformer.dart';

abstract class QueryRunner {
  final Driver driver;

  final Transformer transformer;

  const QueryRunner(this.driver, this.transformer);

  Future<dynamic> query(String query);

  Future<List<Map<String, dynamic>>> find(
      FindOptions options, GeneratedEntity entity);

  Future<int> count(CountOptions options, GeneratedEntity entity);

  Future<dynamic> insert(GeneratedEntity entity, Map<String, dynamic> data);

  Future<dynamic> update(GeneratedEntity entity, Map<String, dynamic> data,
      WhereClause where);

  Future<dynamic> delete(GeneratedEntity entity, WhereClause where);

  // Future<List<String>> getDatabases();

  // Future<List<String>> getSchemas();

  // Future<Table?> getTable(String tableName);

  // Future<List<Table>> getTables();

  Future<bool> hasDatabase(String database);

  // Future<String?> getCurrentDatabase();

  Future<bool> hasSchema(String schema);

  // Future<String?> getCurrentSchema();

  Future<bool> hasTable(dynamic table);

  Future<void> createDatabase(String database, {bool ifNotExists = true});

  Future<void> createSchema(String schema, {bool ifNotExists = true});

  Future<void> createTable(Schema entitySchema,
      {bool ifNotExists = true,
      bool createForeignKeys = true,
      bool createIndices = true});

  String getSqlType(ColumnMetadata column);

  Future<void> dropDatabase(String database, {bool ifExists = true});

  Future<void> dropSchema(String schema, {bool ifExists = true});

  Future<void> dropTable(String table,
      {bool ifExists = true,
      bool dropForeignKeys = true,
      bool dropIndices = true});

  Future<void> addColumn(String table, ColumnMetadata column);

  // Future<void> addColumns(String table, List<ColumnMetadata> columns);

  Future<void> changeColumn(
      String table, ColumnMetadata column, ColumnMetadata newColumn);

  // Future<void> changeColumns(String table, List<ColumnMetadata> columns,
  //     List<ColumnMetadata> newColumns);

  Future<void> dropColumn(String table, String column);

  // Future<void> dropColumns(String table, List<String> columns);

  // Future<void> addForeignKey(String table, RelationMetadata foreignKey);

  // Future<void> addForeignKeys(String table, List<RelationMetadata> foreignKeys);

  // Future<void> dropForeignKey(String table, String foreignKey);

  // Future<void> dropForeignKeys(String table, List<String> foreignKeys);

  // Future<void> createExtension(String s, {bool ifNotExists = true});

  // Future<void> createTables(List<GeneratedEntity> entities,
  //     {bool ifNotExists, bool createForeignKeys, bool createIndices});
}

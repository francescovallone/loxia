import 'dart:io';

import 'package:loxia/loxia.dart';
import 'package:loxia/src/connection.dart';
import 'package:loxia/src/drivers/sqlite/sqlite_query_runner.dart';
import 'package:loxia/src/enums/column_type_enum.dart';
import 'package:loxia/src/query_runner/query_runner.dart';
import 'package:loxia/src/transformers/sql_operators_transformer.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'sqlite_datasource_options.dart';

class SqliteDriver extends Driver<Database> {
  SqliteDriver(super.dataSource);

  @override
  Future<void> afterConnect() {
    return Future.value();
  }

  @override
  Future<void> connect() async {
    sqfliteFfiInit();
    final sqliteOptions = dataSource.options as SqliteDataSourceOptions;
    connection = Connection(await databaseFactoryFfi.openDatabase(
        '${Directory.current.absolute.path}/${sqliteOptions.database}',
        options: OpenDatabaseOptions(
            version: sqliteOptions.version,
            onConfigure: (db) async {
              connection = Connection(db);
              await execute('PRAGMA auto_vacuum = INCREMENTAL;');
              await execute('PRAGMA foreign_keys = ON;');
            },
            onCreate: (db, version) async {
              connection = Connection(db);
              for (var entity in sqliteOptions.entities) {
                await queryRunner.createTable(entity.schema,
                    ifNotExists: true,
                    createForeignKeys: true,
                    createIndices: true);
              }
            },
            onUpgrade: (db, oldVersion, newVersion) async {
              connection = Connection(db);
              for (var migration in sqliteOptions.migrations) {
                if (migration.version > oldVersion &&
                    migration.version <= newVersion) {
                  await migration.up(queryRunner);
                }
              }
              for (var entity in sqliteOptions.entities) {
                final tableExists =
                    await queryRunner.hasTable(entity.schema.table.name);
                if (!tableExists) {
                  await queryRunner.createTable(entity.schema,
                      ifNotExists: true,
                      createForeignKeys: true,
                      createIndices: true);
                }
              }
            },
            onDowngrade: onDatabaseDowngradeDelete)));
  }

  @override
  String createParamter(String parameterName, int index) {
    throw UnimplementedError();
  }

  @override
  Future<void> dispose() async {
    await connection?.internal.close();
  }

  @override
  String escape(String columnName) {
    return '"$columnName"';
  }

  @override
  bool get isConnected => connection?.internal.isOpen ?? false;

  @override
  String get parameterPrefix => throw UnimplementedError();

  @override
  QueryRunner get queryRunner =>
      SqliteQueryRunner(this, SqlOperatorTransformer());

  @override
  List<ColumnType> get supportedTypes => [...ColumnType.values];

  @override
  Future<dynamic> execute(String query) async {
    if (query.startsWith('SELECT ')) {
      return await connection?.internal.rawQuery(query);
    }
    if (query.startsWith('INSERT ')) {
      return await connection?.internal.rawInsert(query);
    }
    if (query.startsWith('UPDATE ')) {
      return await connection?.internal.rawUpdate(query);
    }
    if (query.startsWith('DELETE ')) {
      return await connection?.internal.rawDelete(query);
    }
    return await connection?.internal.execute(query);
  }
}

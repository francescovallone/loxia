import 'dart:io';

import 'package:loxia/loxia.dart';
import 'package:loxia/src/connection.dart';
import 'package:loxia/src/drivers/sqlite/sqlite_query_runner.dart';
import 'package:loxia/src/enums/column_type_enum.dart';
import 'package:loxia/src/query_runner/query_runner.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class SqliteDriver extends Driver<Database> {

  SqliteDriver(super.dataSource);

  @override
  Future<void> afterConnect() async {
    for(final entity in dataSource.entities){
      await queryRunner.createTable(entity);
    }
  }

  @override
  Future<void> connect() async {
    sqfliteFfiInit();
    connection = Connection(
      await databaseFactoryFfi.openDatabase(
        '${Directory.current.absolute.path}/${dataSource.options.database}',
      )
    );
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
  QueryRunner get queryRunner => SqliteQueryRunner(this);

  @override
  List<ColumnType> get supportedTypes => [
    ...ColumnType.values
  ];

  @override
  Future<dynamic> execute(String query) async {
    if(query.contains('SELECT ')){
      return await connection?.internal.rawQuery(query);
    }
    if(query.contains('INSERT ')){
      return await connection?.internal.rawInsert(query);
    }
    if(query.contains('UPDATE ')){
      return await connection?.internal.rawUpdate(query);
    }
    if(query.contains('DELETE ')){
      return await connection?.internal.rawDelete(query);
    }
    return await connection?.internal.execute(query);
  }
  
}
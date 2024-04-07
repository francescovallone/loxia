import 'package:loxia/src/connection.dart';
import 'package:loxia/src/entity/entity.dart';
import 'package:loxia/src/queries/find_options.dart';
import 'package:loxia/src/query_runner/query_runner.dart';

import '../datasource/datasource.dart';
import '../enums/column_type_enum.dart';

mixin DriverOperations {
  Future<List<Map<String, dynamic>>> find(
      FindOptions? options, GeneratedEntity entity);
}

mixin DriverTableOperations {}

abstract class Driver<T> {
  Driver(this.dataSource);

  Connection<T>? connection;

  final DataSource dataSource;

  bool get isConnected;

  String get parameterPrefix;

  List<ColumnType> get supportedTypes;

  Map<String, dynamic> get supportedDefaults;

  Future<void> connect();

  Future<void> afterConnect();

  Future<void> dispose();

  String escape(String columnName);

  String createParamter(String parameterName, int index);

  Future<dynamic> execute(String query);

  QueryRunner get queryRunner;
}

import 'package:loxia/src/entity/entity.dart';
import 'package:loxia/src/queries/find/find_options.dart';
import 'package:loxia/src/query_runner/query_runner.dart';

import '../datasource/datasource.dart';

mixin DriverOperations {
  Future<List<Map<String, dynamic>>> find(
      FindOptions? options, GeneratedEntity entity);
}

mixin DriverTableOperations {}

abstract class Driver {
  Driver(this.connection);

  final DataSource connection;

  bool get isConnected;

  String get parameterPrefix;

  Future<void> connect();

  Future<void> afterConnect();

  Future<void> dispose();

  String escape(String columnName);

  String createParamter(String parameterName, int index);

  QueryRunner get queryRunner;
}

import 'package:loxia/src/entity/entity.dart';
import 'package:loxia/src/queries/find/find_options.dart';
import 'package:loxia/src/query_runner/query_runner.dart';

import '../datasource/datasource.dart';

mixin DriverOperations {

  Future<List<Map<String, dynamic>>> find(FindOptions? options, GeneratedEntity entity);

}

mixin DriverTableOperations {

}

abstract class Driver{

  Driver(this.connection);

  final DataSource connection;

  bool get isConnected;

  Future<void> connect();

  Future<void> dispose();

  String escape(String value);

  QueryRunner get queryRunner;

}
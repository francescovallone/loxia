import 'package:loxia/src/entity/entity.dart';

import '../datasource/datasource.dart';

mixin DriverOperations {

  Future<Map<String, dynamic>> findById(dynamic id);

}

mixin DriverTableOperations {

  Future<void> createTable(
    GeneratedEntity entity,
    {
      bool ifNotExists = false,
    }
  );

  Future<void> dropTable(GeneratedEntity entity);

  Future<bool> hasTable(GeneratedEntity entity);

}

abstract class Driver with DriverOperations, DriverTableOperations{

  Driver(this.connection);

  final DataSource connection;

  bool get isConnected;

  Future<void> connect();

  Future<void> dispose();

  String escape(String value);

  Future<List<Map<String, dynamic>>> query(String query);

}
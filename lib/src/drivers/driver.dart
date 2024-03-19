import 'package:loxia/src/datasource/datasource.dart';
import 'package:loxia/src/entity/entity.dart';

mixin DriverOperations on Driver {

  Future<Map<String, dynamic>> findById(dynamic id);

}

abstract class Driver {

  Driver(this.connection);

  final DataSource connection;

  bool get isConnected;

  Future<void> connect();

  Future<void> dispose();

  String escape(String value);

  Future<List<E>> query<E extends Entity>(String query, E entity);

}
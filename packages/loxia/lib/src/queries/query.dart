import '../drivers/driver.dart';

sealed class QueryDef<T> {

  final String table;

  QueryDef(this.table);

  String? database;

  DriverOperations? _driver;

  DriverOperations get driver {
    if (_driver == null) {
      throw Exception('Driver not initialized');
    }
    return _driver!;
  }

  T init(DriverOperations driver) {
    _driver = driver;
    return this as T;
  }

  Future<void> execute();

  String get query;

}




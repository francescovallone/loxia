import 'package:loxia/src/drivers/sqlite/sqlite_driver.dart';

import '../datasource/datasource.dart';
import '../datasource/options/datasource_options.dart';
import '../enums/database_enum.dart';

import 'driver.dart';
import 'postgres/postgres_driver.dart';

class DriverFactory {
  Driver create<T extends DataSourceOptions>(DataSource connection) {
    final type = connection.options.type;
    switch (type) {
      case DatabaseType.postgres:
        // return PostgresDriver(connection);
      case DatabaseType.sqlite:
        return SqliteDriver(connection);
      default:
        throw Exception('Driver not found');
    }
  }
}

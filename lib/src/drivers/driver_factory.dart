import 'package:loxia/src/datasource/datasource.dart';
import 'package:loxia/src/datasource/options/datasource_options.dart';
import 'package:loxia/src/enums/database_enum.dart';

import 'driver.dart';
import 'postgres_driver.dart';

class DriverFactory {

  Driver create<T extends DataSourceOptions>(DataSource connection) {
    final type = connection.options.type;
    switch(type){
      case DatabaseType.postgres:
        return PostgresDriver(connection);
      default:
        throw Exception('Driver not found');
    }
  }

}
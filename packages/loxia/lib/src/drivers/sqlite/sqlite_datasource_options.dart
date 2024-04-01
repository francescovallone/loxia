import 'package:loxia/src/datasource/options/datasource_options.dart';
import 'package:loxia/src/enums/database_enum.dart';

class SqliteDataSourceOptions extends DataSourceOptions {

  const SqliteDataSourceOptions(
    {
      required super.database,
      super.entities,
      super.migrations,
    }
  ): super(password: '', host: '', port: 0, username: '', type: DatabaseType.sqlite);

  @override
  String toString() {
    return '$runtimeType{database: $database}';
  }
}

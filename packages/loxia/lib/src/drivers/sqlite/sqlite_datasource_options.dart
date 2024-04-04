import 'package:loxia/src/datasource/options/datasource_options.dart';
import 'package:loxia/src/enums/database_enum.dart';

class SqliteDataSourceOptions extends DataSourceOptions {
  final int version;

  const SqliteDataSourceOptions({
    required super.database,
    this.version = 1,
    super.entities,
    super.migrations,
  })  : assert(version > 0, 'The schema version must be greater than 0'),
        super(
            password: '',
            host: '',
            port: 0,
            username: '',
            type: DatabaseType.sqlite);

  @override
  String toString() {
    return '$runtimeType{database: $database, version: $version}';
  }
}

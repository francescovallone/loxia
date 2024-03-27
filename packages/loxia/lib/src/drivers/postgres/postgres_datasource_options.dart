import 'package:loxia/src/datasource/options/datasource_options.dart';
import 'package:postgres/postgres.dart';

class PostgresDataSourceOptions extends DataSourceOptions {
  final SslMode sslMode;

  const PostgresDataSourceOptions(
      {required super.host,
      required super.port,
      required super.username,
      required super.password,
      super.database = 'postgres',
      super.entities,
      super.migrations,
      this.sslMode = SslMode.disable});

  @override
  String toString() {
    return 'PostgresDataSourceOptions{host: $host, port: $port, database: $database, username: $username, sslMode: $sslMode}';
  }
}

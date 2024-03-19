import 'package:loxia/src/enums/database_enum.dart';
import 'package:postgres/postgres.dart';

abstract class DataSourceOptions {
  final DatabaseType type;
  final String host;
  final int port;
  final String database;
  final String username;
  final String password;

  const DataSourceOptions({
    required this.host,
    required this.port,
    required this.database,
    required this.username,
    required this.password,
    this.type = DatabaseType.postgres,
  });

  @override
  String toString() {
    return 'DataSourceOptions{type: $type, host: $host, port: $port, database: $database, username: $username}';
  }
  
}

class PostgresDataSourceOptions extends DataSourceOptions{

  final SslMode sslMode;

  const PostgresDataSourceOptions({
    required super.host, 
    required super.port, 
    required super.database, 
    required super.username, 
    required super.password,
    this.sslMode = SslMode.disable
  });

  @override
  String toString() {
    return 'PostgresDataSourceOptions{host: $host, port: $port, database: $database, username: $username, sslMode: $sslMode}';
  }

}
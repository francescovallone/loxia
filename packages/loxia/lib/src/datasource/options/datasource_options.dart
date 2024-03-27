import 'package:loxia/src/entity/entity.dart';
import 'package:loxia/src/migrations/migration.dart';

import '../../enums/database_enum.dart';

abstract class DataSourceOptions {
  final DatabaseType type;
  final String host;
  final int port;
  final String database;
  final String username;
  final String password;
  final List<GeneratedEntity> entities;
  final List<Migration> migrations;

  const DataSourceOptions(
      {required this.host,
      required this.port,
      required this.database,
      required this.username,
      required this.password,
      this.entities = const [],
      this.type = DatabaseType.postgres,
      this.migrations = const []});

  @override
  String toString() {
    return 'DataSourceOptions{type: $type, host: $host, port: $port, database: $database, username: $username}';
  }
}

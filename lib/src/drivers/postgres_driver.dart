import 'package:postgres/postgres.dart';

import 'driver.dart';
import 'options/driver_options.dart';

class PostgresDriver extends Driver<PostgresDriverOptions>{

  late final Connection _connection;

  @override
  Future<void> dispose() async {
    await _connection.close();
  }

  Future<void> init(PostgresDriverOptions options) async {
    _connection = await Connection.open(
      Endpoint(
        host: options.host,
        port: options.port,
        database: options.database,
        username: options.username,
        password: options.password,
      ),
      settings: ConnectionSettings(
        sslMode: options.sslMode
      )
    );
  }

  

}
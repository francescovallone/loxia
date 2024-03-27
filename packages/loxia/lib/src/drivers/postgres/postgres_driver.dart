import 'package:loxia/loxia.dart';

import 'package:postgres/postgres.dart';

import 'postgres_datasource_options.dart';
import 'postgres_query_runner.dart';

class PostgresDriver extends Driver {
  Connection? postgres;

  PostgresDriver(super.connection);

  @override
  late final PostgresQueryRunner queryRunner;

  @override
  Future<void> connect() async {
    postgres = await Connection.open(
        Endpoint(
          host: connection.options.host,
          port: connection.options.port,
          username: connection.options.username,
          password: connection.options.password,
          database: connection.options.database,
        ),
        settings: ConnectionSettings(
          sslMode: (connection.options as PostgresDataSourceOptions).sslMode,
        ));
    queryRunner = PostgresQueryRunner(postgres!);
  }

  @override
  Future<void> dispose() async {
    await postgres?.close();
  }

  @override
  String escape(String value) {
    // TODO: implement escape
    throw UnimplementedError();
  }

  @override
  bool get isConnected => postgres?.isOpen ?? false;
}

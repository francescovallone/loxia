import 'package:loxia/loxia.dart';

import 'package:postgres/postgres.dart';

import 'postgres_datasource_options.dart';
import 'postgres_query_runner.dart';

class PostgresDriver extends Driver {
  
  Connection? postgres;

  @override
  final String parameterPrefix = '\$';

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
    queryRunner = PostgresQueryRunner(this);
  }

  @override
  Future<void> afterConnect() async {
    await queryRunner.createExtension(
      'uuid-ossp',
      ifNotExists: true,
    );
    await queryRunner.createTables(connection.options.entities, ifNotExists: true);
    for (var entity in connection.options.entities) {
      await queryRunner.completeTable(entity);
    }
  }

  @override
  Future<void> dispose() async {
    await postgres?.close();
  }

  Future<Result> execute(
    String query,
    {
      QueryMode? queryMode,
      Map<String, dynamic> parameters = const {},
      bool ignoreRows = false,
      Duration? timeout,
    }
  ) async {
    return await postgres!.execute(
      query,
      ignoreRows: ignoreRows,
      timeout: timeout,
      parameters: parameters,
      queryMode: queryMode,
    );
  }

  @override
  String escape(String columnName) {
    return '"$columnName"';
  }

  @override
  String createParamter(String parameterName, int index){
    return '$parameterPrefix${(index + 1)}';
  }

  @override
  bool get isConnected => postgres?.isOpen ?? false;
}

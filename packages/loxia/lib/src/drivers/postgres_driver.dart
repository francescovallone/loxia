import '../datasource/options/datasource_options.dart';
import 'driver.dart';
import 'package:postgres/postgres.dart';

class PostgresDriver extends Driver {

  Connection? postgres;

  PostgresDriver(super.connection);

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
      )
    );
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
  Future<List<Map<String, dynamic>>> query(String query) async {
    if(postgres == null){
      throw Exception('Connection not established');
    }
    final result = await postgres!.execute(query);
    return result.map((row) {
      final map = <String, dynamic>{};
      for (var i = 0; i < row.length; i++) {
        map[result.schema.columns[i].columnName!] = row[i];
      }
      return map;
    }).toList();
  }
  
  @override
  // TODO: implement isConnected
  bool get isConnected => postgres?.isOpen ?? false;

}
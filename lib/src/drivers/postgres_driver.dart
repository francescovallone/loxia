import 'package:loxia/src/datasource/options/datasource_options.dart';
import 'package:loxia/src/drivers/driver.dart';
import 'package:loxia/src/entity/entity.dart';
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
  Future<List<E>> query<E extends Entity>(String query, E entity) async {
    if(postgres == null){
      throw Exception('Connection not established');
    }
    final result = await postgres!.execute(query);
    final rows = result.map<E>((row) {
      final map = <String, dynamic>{};
      for (var i = 0; i < row.length; i++) {
        map[result.schema.columns[i].columnName!] = row[i];
      }
      
      return entity.fromResultSet(map);
    }).toList();
    return rows;
  }
  
  @override
  // TODO: implement isConnected
  bool get isConnected => postgres?.isOpen ?? false;

}
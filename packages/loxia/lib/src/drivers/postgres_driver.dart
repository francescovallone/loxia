import 'package:loxia/loxia.dart';
import 'package:loxia/src/entity/entity.dart';

import 'driver.dart';
import 'package:postgres/postgres.dart';

class PostgresDriver extends Driver{

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
  Future<void> createTable(
    GeneratedEntity entity,
    {
      bool ifNotExists = false,
    }
  ) async {
    if(ifNotExists){
      final table = await hasTable(entity);
      if(table){
        return Future.value();
      }
    }
    final columns = entity.schema.fields.map((e) => buildCreateColumn(e)).join(', ');
    final buffer = StringBuffer('CREATE TABLE ${escapeString(entity.table)} ($columns)'); 
    // final primaryColumn = entity.schema.fields.where((e) => e.primaryKey).firstOrNull;
    // if(primaryColumn != null){
    //   print(primaryColumn.name);
    //   buffer.write(' CONSTRAINT ${primaryColumn.name} PRIMARY KEY (${primaryColumn.name})');
    // }
    await postgres?.execute(buffer.toString());
  }

  String escapeString(String value) => '"$value"';

  @override
  Future<bool> hasTable(GeneratedEntity entity) async {
    final query = 'SELECT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = \'${entity.table}\') AS table_existence;';
    final result = await postgres?.execute(query);
    return result?.firstOrNull?.firstOrNull == true;
  }

  String buildCreateColumn(FieldSchema field) {
    final buffer = StringBuffer('"${field.name}"');
    
    if(field.type == 'String'){
      buffer.write(' TEXT');
    }
    return buffer.toString();
  }

  //         let c = '"' + column.name + '"'
        // if (
        //     column.isGenerated === true &&
        //     column.generationStrategy !== "uuid"
        // ) {
        //     if (column.generationStrategy === "identity") {
        //         // Postgres 10+ Identity generated column
        //         const generatedIdentityOrDefault =
        //             column.generatedIdentity || "BY DEFAULT"
        //         c += ` ${column.type} GENERATED ${generatedIdentityOrDefault} AS IDENTITY`
        //     } else {
        //         // classic SERIAL primary column
        //         if (
        //             column.type === "integer" ||
        //             column.type === "int" ||
        //             column.type === "int4"
        //         )
        //             c += " SERIAL"
        //         if (column.type === "smallint" || column.type === "int2")
        //             c += " SMALLSERIAL"
        //         if (column.type === "bigint" || column.type === "int8")
        //             c += " BIGSERIAL"
        //     }
        // }
        // if (column.type === "enum" || column.type === "simple-enum") {
        //     c += " " + this.buildEnumName(table, column)
        //     if (column.isArray) c += " array"
        // } else if (!column.isGenerated || column.type === "uuid") {
        //     c += " " + this.connection.driver.createFullType(column)
        // }

        // // Postgres only supports the stored generated column type
        // if (column.generatedType === "STORED" && column.asExpression) {
        //     c += ` GENERATED ALWAYS AS (${column.asExpression}) STORED`
        // }

        // if (column.charset) c += ' CHARACTER SET "' + column.charset + '"'
        // if (column.collation) c += ' COLLATE "' + column.collation + '"'
        // if (column.isNullable !== true) c += " NOT NULL"
        // if (column.default !== undefined && column.default !== null)
        //     c += " DEFAULT " + column.default
        // if (
        //     column.isGenerated &&
        //     column.generationStrategy === "uuid" &&
        //     !column.default
        // )
        //     c += ` DEFAULT ${this.driver.uuidGenerator}`

        // return c
  
  @override
  // TODO: implement isConnected
  bool get isConnected => postgres?.isOpen ?? false;
  
  @override
  Future<void> dropTable(GeneratedEntity entity) {
    // TODO: implement dropTable
    throw UnimplementedError();
  }
  
  @override
  Future<Map<String, dynamic>> findById(id) {
    // TODO: implement findById
    throw UnimplementedError();
  }

}
import 'package:loxia/loxia.dart';
import 'package:loxia/src/entity/entity.dart';
import 'package:loxia/src/enums/order_by_enum.dart';
import 'package:loxia/src/queries/find/find_options.dart';

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
    final buffer = StringBuffer('CREATE TABLE ${escapeString(entity.table)} ($columns,'); 
    final primaryColumn = entity.schema.fields.where((e) => e.primaryKey).firstOrNull;
    if(primaryColumn != null){
      print(primaryColumn.name);
      buffer.write(' CONSTRAINT ${escapeString('${primaryColumn.name}_pk')} PRIMARY KEY (${escapeString(primaryColumn.name)})');
    }
    buffer.write(');');
    print(buffer.toString());
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
    if(field.type == 'bool'){
      buffer.write(' BOOLEAN');
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
  bool get isConnected => postgres?.isOpen ?? false;
  
  @override
  Future<void> dropTable(GeneratedEntity entity) {
    // TODO: implement dropTable
    throw UnimplementedError();
  }
  
  @override
  Future<List<Map<String, dynamic>>> find(FindOptions options, GeneratedEntity entity) async {
    final stringQuery = StringBuffer('SELECT');
    if(options.select.isEmpty){
      stringQuery.write(' *');
    } else {
      final columns = options.select.map((column) => escapeString(column)).toList();
      stringQuery.write(' ${columns.join(', ')}');
    }
    stringQuery.write(' FROM ${escapeString(entity.table)}');
    stringQuery.write(_buildWhereClause(options.where));
    stringQuery.write(_buildOrderByClause(options.orderBy));
    if(options.limit != null){
      stringQuery.write(' LIMIT ${options.limit}');
    }
    if(options.skip != null){
      stringQuery.write(' OFFSET ${options.skip}');
    }
    print(stringQuery.toString());
    return await query(stringQuery.toString());
  }

  String _buildWhereClause(List<Map<String, dynamic>> whereClauses) {
    final buffer = StringBuffer();
    if(whereClauses.isNotEmpty){
      buffer.write(' WHERE');
      final where = whereClauses.map((e) => e.entries.map((e) => "(${escapeString(e.key)} = '${e.value}')").join(' AND ')).join(' OR ');
      buffer.write(' $where');
    }
    return buffer.toString();
  }

  String _buildOrderByClause(Map<String, OrderBy> orderByClause) {
    final buffer = StringBuffer();
    if(orderByClause.isNotEmpty){
      buffer.write(' ORDER BY');
      final orderBy = orderByClause.entries.map((e) => '${escapeString(e.key)} ${e.value == OrderBy.asc ? 'ASC' : 'DESC'}').join(', ');
      buffer.write(' $orderBy');
    }
    return buffer.toString();
  }

}
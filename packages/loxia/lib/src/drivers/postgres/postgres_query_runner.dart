import 'package:loxia/src/entity/entity.dart';
import 'package:loxia/src/entity/entity_schema.dart';
import 'package:loxia/src/enums/order_by_enum.dart';
import 'package:loxia/src/queries/find/find_options.dart';
import 'package:loxia/src/query_runner/query_runner.dart';
import 'package:postgres/postgres.dart';

class PostgresQueryRunner extends QueryRunner{

  final Connection _connection;

  PostgresQueryRunner(this._connection);

  @override
  Future<List<Map<String, dynamic>>> query(String query) async {
    final result = await _connection.execute(query);
    return result.map((row) {
      final map = <String, dynamic>{};
      for (var i = 0; i < row.length; i++) {
        map[result.schema.columns[i].columnName!] = row[i];
      }
      return map;
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getTableColumns(String table) async {
    final query = 'SELECT column_name, column_default, is_nullable, data_type FROM information_schema.columns WHERE table_name = \'$table\' order by ordinal_position asc;';
    final result = await _connection.execute(query);
    return result.map((e) => {
      'name': e[0],
      'default': e[1],
      'nullable': e[2] == 'YES',
      'type': e[3],
    }).toList();
  }

  Future<void> addColumn(FieldSchema field, String table) async {
    final column = buildCreateColumn(field);
    final query = 'ALTER TABLE ${escapeString(table)} ADD COLUMN $column;';
    await _connection.execute(query);
  }

  Future<void> deleteColumn(String table, String column) async {
    final query = 'ALTER TABLE ${escapeString(table)} DROP COLUMN "$column";';
    await _connection.execute(query);
  }

  Future<void> checkColumns(List<Map<String, dynamic>> cachedColumns, List<FieldSchema> fields, String table) async {
    if(cachedColumns.length > fields.length){
      final differences = fields.map((e) => e.name).toSet();
      for (var i = 0; i < cachedColumns.length; i++) {
        final column = cachedColumns[i];
        if(!differences.contains(column['name'])){
          await deleteColumn(table, column['name']);
        }
      }
    }
    if(cachedColumns.length < fields.length){
      final differences = cachedColumns.map((e) => e['name']).toSet();
      for (var i = 0; i < fields.length; i++) {
        final field = fields[i];
        if(!differences.contains(field.name)){
          await addColumn(field, table);
        }
      }
    }
    for (var i = 0; i < fields.length; i++) {
      final field = fields[i];
      final cachedColumn = cachedColumns[i];
      final query = StringBuffer('ALTER TABLE ${escapeString(table)} ALTER COLUMN "${cachedColumn['name']}"');
      final type = getColumnType(field);
      if(type.toLowerCase() != cachedColumn['type']){
        query.write(' TYPE $type;');
        await _connection.execute(query.toString());
      }
      if(field.nullable != cachedColumn['nullable']){
        query.write(' SET ${field.nullable ? 'NULL' : 'NOT NULL'};');
        await _connection.execute(query.toString());
      }
      if((field.defaultValue != null && cachedColumn['default'] != null) || field.defaultValue.toString() != (cachedColumn['default'].toString())){
        query.write(' SET DEFAULT ');
        query.write(field.defaultValue is String ? "'${field.defaultValue}'" : field.defaultValue);
        query.write(';');
        await _connection.execute(query.toString());
      }
      if(field.name != cachedColumn['name']){
        query.write(' RENAME COLUMN ${cachedColumn['name']} TO ${field.name};');
        await _connection.execute(query.toString());
      }
    }
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
      final cachedColumns = await getTableColumns(entity.table);
      if(table){
        await checkColumns(cachedColumns, entity.schema.fields, entity.table);
        return Future.value();
      }
    }
    final columns = entity.schema.fields.map((e) => buildCreateColumn(e)).join(', ');
    final buffer = StringBuffer('CREATE TABLE ${escapeString(entity.table)} ($columns,'); 
    final primaryColumn = entity.schema.fields.where((e) => e.primaryKey).firstOrNull;
    if(primaryColumn != null){
      buffer.write(' CONSTRAINT ${escapeString('${entity.table}_${primaryColumn.name}_pk')} PRIMARY KEY (${escapeString(primaryColumn.name)})');
    }
    buffer.write(');');
    await _connection.execute(buffer.toString());
  }

  @override
  Future<bool> hasTable(GeneratedEntity entity) async {
    final query = 'SELECT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = \'${entity.table}\') AS table_existence;';
    final result = await _connection.execute(query);
    return result.firstOrNull?.firstOrNull == true;
  }

  String buildCreateColumn(FieldSchema field) {
    final buffer = StringBuffer('"${field.name}"');
    
    buffer.write(' ${getColumnType(field)}');
    if(!field.nullable) {
      buffer.write(' NOT NULL');
    }
    if(field.defaultValue != null){
      buffer.write(' DEFAULT ${field.defaultValue is String ? "'${field.defaultValue}'" : field.defaultValue}');
    }
    if(field.unique){
      buffer.write(' UNIQUE');
    }
    if(field.uuid){
      buffer.write(' DEFAULT uuid_generate_v4()');
    }
    return buffer.toString();
  }

  @override
  Future<List<Map<String, dynamic>>> find(FindOptions? options, GeneratedEntity entity) async {
    final stringQuery = StringBuffer('SELECT');
    if(options == null){
      stringQuery.write(' *');
      stringQuery.write(' FROM ${escapeString(entity.table)}');
      return await query(stringQuery.toString());
    }
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

  String escapeString(String value) => '"$value"';
  
  @override
  Future<void> dropTable(GeneratedEntity entity) {
    // TODO: implement dropTable
    throw UnimplementedError();
  }

  @override
  Future<void> createExtension(String s, {bool ifNotExists = true}) async {
    final version = await _connection.execute('SHOW SERVER_VERSION;');
    final majorVersion = num.parse(version.first.firstOrNull?.toString().split(' ')[0] ?? '0').toInt();
    if(majorVersion < 9){
      throw Exception('''
        PostgreSQL version $majorVersion is not supported.
        Please upgrade to a version greater than 9.
        Or follow 
      ''');
    }
    await _connection.execute('CREATE EXTENSION${ifNotExists ? ' IF NOT EXISTS' : ''} "$s";');
  }
  
  String getColumnType(FieldSchema field) {
    if(field.uuid){
      return 'UUID';
    }
    if(field.explicitType != null) {
      return field.explicitType!;
    }
    switch (field.type) {
      case 'String':
        return 'TEXT';
      case 'int':
        return 'INTEGER';
      case 'double':
        return 'DOUBLE PRECISION';
      case 'bool':
        return 'BOOLEAN';
      case 'DateTime':
        return 'TIMESTAMP';
      default:
        return 'TEXT';
    }
  }

}
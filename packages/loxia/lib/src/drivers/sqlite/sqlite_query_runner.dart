import 'package:loxia/src/entity/entity.dart';
import 'package:loxia/src/entity/entity_schema.dart';
import 'package:loxia/src/metadata/column_metadata.dart';
import 'package:loxia/src/queries/find_options.dart';
import 'package:loxia/src/queries/where_clause.dart';
import 'package:loxia/src/query_runner/query_runner.dart';

class SqliteQueryRunner extends QueryRunner {

  SqliteQueryRunner(super.driver, super.transformer);

  @override
  Future<bool> hasTable(dynamic table) async {
    String tableName = table is String ? table : table.tableName;
    final result = await query('''
      SELECT name
      FROM sqlite_master
      WHERE type = 'table'
      AND name = '$tableName';
    ''');
    return List<Map<String, dynamic>>.from(result ?? []).isNotEmpty;
  }
  
  @override
  Future query(String query) async {
    return await driver.execute(query);
  }

  @override
  Future<void> createTable(
    Schema entitySchema, 
    {
      bool ifNotExists = true, 
      bool createForeignKeys = true, 
      bool createIndices = true
    }
  ) async {
    if(ifNotExists){
      final tableExists = await hasTable(entitySchema.table.name);
      if(tableExists){
        dropTable(entitySchema.table.name);
      }
    }

    final columns = entitySchema.table.columns.map((column) {
      if(column.primaryKey && column.uuid){
        throw Exception('Primary key column cannot be a UUID in SQLite');
      }
      final type = getSqlType(column);
      return '''
        ${column.name} $type ${column.primaryKey ? 'PRIMARY KEY ' : ''}${column.autoIncrement ? 'AUTOINCREMENT ': ''}${column.nullable ? '' : 'NOT NULL '}${column.unique ? 'UNIQUE ' : ''}${column.defaultValue != null ? 'DEFAULT ${column.type == 'bool' ? column.defaultValue ? 1 : 0 : column.defaultValue}' : ''}
      '''.trim();
    }).join(',\n');

    final querySql = '''
      CREATE TABLE ${ifNotExists ? 'IF NOT EXISTS ' : ''}${driver.escape(entitySchema.table.name)} (
        $columns
      );
    ''';
    await query(querySql);
  }
  
  @override
  Future<void> dropTable(String table, {bool ifExists = true, bool dropForeignKeys = true, bool dropIndices = true}) async {
    await query('''DROP TABLE ${ifExists ? 'IF EXISTS ' : ''}$table;''');
  }
  
  @override
  String getSqlType(ColumnMetadata column) {
    final type = column.explicitType ?? column.type;
    switch(type){
      case 'String':
        return 'TEXT';
      case 'int':
        return 'INTEGER';
      case 'double':
        return 'REAL';
      case 'bool':
        return 'INTEGER';
      case 'DateTime':
        return 'TEXT';
    }
    for (var supportedType in driver.supportedTypes) {
      if(supportedType.toString().split('.').last == type){
        return type;
      }
    }
    throw Exception('Column ${column.name} uses unsupported type $type');
  }
  
  @override
  Future<void> changeColumn(String table, ColumnMetadata column, ColumnMetadata newColumn) async {
    await query(
      '''
        ALTER TABLE $table
        RENAME COLUMN ${column.name} TO ${newColumn.name};
      '''
    );
  }
  
  @override
  Future<void> createDatabase(String database, {bool ifNotExists = true}) {
    throw UnimplementedError();
  }
  
  @override
  Future<void> createSchema(String schema, {bool ifNotExists = true}) {
    throw UnimplementedError();
  }
  
  @override
  Future<void> dropColumn(String table, String column) {
    throw UnimplementedError();
  }
  
  @override
  Future<void> dropDatabase(String database, {bool ifExists = true}) {
    throw UnimplementedError();
  }
  
  @override
  Future<void> dropSchema(String schema, {bool ifExists = true}) {
    throw UnimplementedError();
  }
  
  @override
  Future<bool> hasDatabase(String database) {
    throw UnimplementedError();
  }
  
  @override
  Future<bool> hasSchema(String schema) {
    throw UnimplementedError();
  }
  
  @override
  Future<void> addColumn(String table, ColumnMetadata column) async {
    await query(
      '''
        ALTER TABLE $table
        ADD COLUMN ${column.name} ${getSqlType(column)} ${column.primaryKey ? 'PRIMARY KEY ' : ''}${column.autoIncrement ? 'AUTOINCREMENT ': ''}${column.nullable ? '' : 'NOT NULL '}${column.unique ? 'UNIQUE ' : ''}${column.defaultValue != null ? 'DEFAULT ${column.type == 'bool' ? column.defaultValue ? 1 : 0 : column.defaultValue}' : ''};
      '''
    );
  }
  
  @override
  Future<List<Map<String, dynamic>>> find(FindOptions options, GeneratedEntity entity) async {
    StringBuffer querySql = StringBuffer('SELECT ');
    if(options.select.isEmpty){
      querySql.write('*');
    } else {
      querySql.write(options.select.join(', '));
    }
    querySql.write(' FROM ${entity.schema.table.name}');
    
    if(options.where != null){
      querySql.write(' WHERE ${WhereClause.build(options.where!, transformer)}');
    }

    // if(options.orderBy.isNotEmpty){
    //   querySql.write(' ORDER BY ${options.orderBy.entries.map((e) => '${e.key} ${e.value}').join(', ')}');
    // }

    if(options.limit != null){
      querySql.write(' LIMIT ${options.limit}');
    }

    if(options.skip != null){
      querySql.write(' OFFSET ${options.skip}');
    }
    final result = await query(querySql.toString());
    final transformedResult = List<Map<String, dynamic>>.empty(growable: true);
    for(Map<String, dynamic> obj in result){
      final newElement = Map<String, dynamic>.fromEntries(obj.entries.map((e) {
        final column = entity.schema.table.columns.where((element) => element.name == e.key).firstOrNull;
        if(column?.type == 'DateTime'){
          return MapEntry(e.key, DateTime.parse(e.value));
        }
        if(column?.type == 'bool'){
          return MapEntry(e.key, e.value == 1);
        }
        return MapEntry(e.key, e.value);
      }));
      transformedResult.add(newElement);
    }
    return transformedResult;
  }
  
  @override
  Future insert(GeneratedEntity entity, Map<String, dynamic> data) async {
    assert(data.isNotEmpty, 'Data cannot be empty');
    final entityColumns = entity.schema.table.columns;
    for(var column in entityColumns){
      if(
        (!data.keys.contains(column.name) || !data.keys.contains(column.aliasName)) &&
        (column.nullable == false && column.defaultValue == null && column.autoIncrement == false)
      ){
        throw Exception('Column ${column.name} is required');
      }
      if(column.autoIncrement && data.containsKey(column.name) || data.containsKey(column.aliasName)){
        data.remove(column.name);
      }
    }
    final buffer = StringBuffer('INSERT INTO ${entity.schema.table.name} (');

    final columns = data.keys.join(', ');

    buffer.write(columns);
    buffer.write(') VALUES (');
    final values = data.values.map((e) {
      if(e is String){
        return "'$e'";
      }
      if(e is DateTime){
        return "'${e.toIso8601String()}'";
      }
      if(e is bool){
        return e ? 1 : 0;
      }
      return e;
    }).join(', ');
    buffer.write(values);
    buffer.write(');');
    return await query(buffer.toString());
  }
  
  @override
  Future<dynamic> update(GeneratedEntity entity, Map<String, dynamic> data, List<Map<String, dynamic>> where) async {
    assert(where.isEmpty, 'Where clause is required for update operation');
    assert(data.isEmpty, 'Data cannot be empty');
    final querySql = StringBuffer('UPDATE ${entity.schema.table.name} SET ');
    final values = data.entries.map((e) {
      if(e.value is String){
        return "${e.key} = '${e.value}'";
      }
      if(e.value is DateTime){
        return "${e.key} = '${e.value.toIso8601String()}'";
      }
      if(e.value is bool){
        return "${e.key} = ${e.value ? 1 : 0}";
      }
      return "${e.key} = ${e.value}";
    }).join(', ');

    querySql.write(values);

    if(where.isNotEmpty){
      querySql.write(' WHERE ${where.map((e) => '(${e.entries.map((e) => '${e.key} = ${e.value}').join(' AND ')})').join(' OR ')}');
    }
    
    return await query(querySql.toString());
  }

  @override
  Future<dynamic> delete(GeneratedEntity entity, Map<String, dynamic> where) async {
    assert(where.isNotEmpty, 'Where clause is required for delete operation');
    final querySql = StringBuffer('DELETE FROM ${entity.schema.table.name} WHERE ');
    final values = where.entries.map((e) {
      if(e.value is String){
        return "${e.key} = '${e.value}'";
      }
      if(e.value is DateTime){
        return "${e.key} = '${e.value.toIso8601String()}'";
      }
      if(e.value is bool){
        return "${e.key} = ${e.value ? 1 : 0}";
      }
      return "${e.key} = ${e.value}";
    }).join(' AND ');

    querySql.write(values);
    return await query(querySql.toString());
  }
  

}
import 'package:loxia/src/drivers/sqlite/sqlite_result_parser.dart';
import 'package:loxia/src/entity/entity.dart';
import 'package:loxia/src/entity/entity_schema.dart';
import 'package:loxia/src/enums/relation_type_enum.dart';
import 'package:loxia/src/metadata/column_metadata.dart';
import 'package:loxia/src/queries/find_options.dart';
import 'package:loxia/src/queries/where_clause.dart';
import 'package:loxia/src/query_runner/query_runner.dart';

class SqliteQueryRunner extends QueryRunner {

  final List<GeneratedEntity> _entities = [];

  SqliteQueryRunner(super.driver, super.transformer){
    _entities.addAll(driver.dataSource.options.entities);
  }

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

    String columns = entitySchema.table.columns.map((column) {
      if(column.primaryKey && column.uuid){
        throw Exception('Primary key column cannot be a UUID in SQLite');
      }
      final type = getSqlType(column);
      return '''
        ${column.name} $type ${column.primaryKey ? 'PRIMARY KEY ' : ''}${column.autoIncrement ? 'AUTOINCREMENT ': ''}${column.nullable ? '' : 'NOT NULL '}${column.unique ? 'UNIQUE ' : ''}${column.defaultValue != null ? 'DEFAULT ${column.type == 'bool' ? column.defaultValue ? 1 : 0 : column.defaultValue}' : ''}
      '''.trim();
    }).join(',\n');

    final relations = entitySchema.table.relations.map((relation) {
      String? referenceColumnName = relation.referenceColumn;
      ColumnMetadata referenceColumn;
      final referenceTable = _entities.where((element) => element.runtimeType == relation.inverseEntity).first.schema.table;
      if(referenceColumnName == null){
        referenceColumn = referenceTable.columns.where((element) => element.primaryKey).first;
        referenceColumnName = referenceColumn.name;
      }else{
        referenceColumn = referenceTable.columns.where((element) => element.name == referenceColumnName).first;
      }
      if(relation.type == RelationType.oneToMany){
       return ''; 
      }
      columns = '''
          $columns,
          ${relation.column} ${getSqlType(referenceColumn)} ${referenceColumn.nullable ? '' : 'NOT NULL '}
        ''';
      return '''
        FOREIGN KEY (${relation.column}) REFERENCES ${referenceTable.name}($referenceColumnName)
      '''.trim();
    }).join(',\n');

    final querySql = '''
      CREATE TABLE ${ifNotExists ? 'IF NOT EXISTS ' : ''}${driver.escape(entitySchema.table.name)} (
        $columns
        ${relations.isNotEmpty ? ',\n$relations' : ''}
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
    assert(
      options.select.any((element) => element.contains('.')) && options.relations.isNotEmpty,
      'Selecting columns from a relation requires a relation to be defined'
    );
    final relationColumnsInSelect = options.select.where((element) => element.contains('.')).map((e) => e.split('.').first).toSet();
    final relations = Map<String, bool>.from(options.relations);
    if(relationColumnsInSelect.isNotEmpty){
      assert(
        relations.keys.any((element) => relationColumnsInSelect.contains(element)),
        'Selecting columns from a relation requires a relation to be defined'
      );
      for(final relation in relationColumnsInSelect){
        relations.putIfAbsent(relation, () => true);
      }
    }
    StringBuffer querySql = StringBuffer('SELECT ');
    final columns = _getColumns(entity, relations.keys, options.select);
    querySql.write(columns.join(', '));
    querySql.write(' FROM ${entity.schema.table.name}');
    if(relations.isNotEmpty){
      for(var relation in entity.schema.table.relations){
        final referenceTable = _entities.where((element) => element.runtimeType == relation.entity).first.schema.table;
        querySql.write(' LEFT JOIN ${referenceTable.name} ON ${entity.schema.table.name}.${relation.column} = ${referenceTable.name}.${referenceTable.columns.where((element) => element.primaryKey).first.name}');
      }
    }

    if(options.where != null){
      querySql.write(' WHERE ${WhereClause.build(options.where!, transformer, entity.schema.table.name)}');
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
    print(querySql);
    final result = await query(querySql.toString());
    final transformedResult = SqliteResultParser(
      entity,
      _entities
    ).parse(result);
    return transformedResult;
  }

  List<String> _getColumns(GeneratedEntity entity, Iterable<String> relations, List<String> select){
    final table = entity.schema.table;
    final sanitizedSelect = select.where((element) => !element.contains('.'));
    final columns = List<String>.from([
      ...table.columns.map((column) => column.name).where((element) => sanitizedSelect.isEmpty || sanitizedSelect.contains(element)),
      ...table.relations.map((e) => e.column).where((element) =>  sanitizedSelect.isEmpty || sanitizedSelect.contains(element))
    ].map((e) => '${table.name}.$e'));
    final relationsTable = table.relations.where((element) => relations.isNotEmpty && relations.contains(element.column));
    for(var relation in relationsTable){
      final referenceTable = _entities.where((element) => element.runtimeType == relation.entity).first.schema.table;
      final referenceColumns = referenceTable.columns.where((element) => select.contains('${referenceTable.name}.${element.name}') || select.isEmpty);
      for(final relationColumn in referenceColumns){
        final index = columns.indexOf(relationColumn.name);
        if(index > -1){
          columns[index] = '${entity.schema.table.name}.${columns[index]}';
          columns.add('${referenceTable.name}.${relationColumn.name} as ${referenceTable.name}_${relationColumn.name}');
        }else{
          columns.add('${referenceTable.name}.${relationColumn.name}');
        }
      }
    }
    return columns;
    
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
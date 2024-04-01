import 'package:loxia/src/entity/entity.dart';
import 'package:loxia/src/query_runner/query_runner.dart';

class SqliteQueryRunner extends QueryRunner {

  SqliteQueryRunner(super.driver);

  @override
  Future<bool> hasTable(dynamic table) async {
    String tableName = table is String ? table : table.tableName;
    final result = await query('''
      SELECT name
      FROM sqlite_master
      WHERE type = 'table'
      AND name = '$tableName';
    ''');
    return List<Map<String, dynamic>>.from(result).isNotEmpty;
  }
  
  @override
  Future query(String query) async {
    return await driver.execute(query);
  }

  @override
  Future<void> createTable(
    GeneratedEntity entity, 
    {
      bool ifNotExists = true, 
      bool createForeignKeys = true, 
      bool createIndices = true
    }
  ) async {
    if(ifNotExists){
      final tableExists = await hasTable(entity.table.name);
      print(tableExists);
    }
  }
  

}
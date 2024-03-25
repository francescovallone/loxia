import 'package:loxia/src/entity/entity.dart';
import 'package:loxia/src/queries/find/find_options.dart';

abstract class QueryRunner {

  Future<dynamic> query(String query);

  Future<List<Map<String, dynamic>>> find(FindOptions? options, GeneratedEntity entity);

  Future<void> createTable(
    GeneratedEntity entity,
    {
      bool ifNotExists = false,
    }
  );

  Future<void> dropTable(GeneratedEntity entity);

  Future<bool> hasTable(GeneratedEntity entity);

  Future<void> createExtension(String s, {bool ifNotExists = true});

}
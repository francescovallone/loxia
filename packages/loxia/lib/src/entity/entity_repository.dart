import '../drivers/driver.dart';
import 'entity_definition.dart';

final class EntityRepository<E>{

  late final EntityDefinition<E> _entityDefinition;
  late final Type entityType;
  late final Driver _driver;

  EntityRepository();

  void init(Driver driver, EntityDefinition<E> entityDefinition){
    _driver = driver;
    _entityDefinition = entityDefinition;
    entityType = entityDefinition.entity;
  }

  // Future<E> findById(dynamic id) async {
  //   // final result = await _driver.findById(id);
  //   // return _entityDefinition.resultMapper(result);
  //   return 
  // }

  Future<List<E>> query(String query) async {
    final result = await _driver.query(query);
    return result.map((e) => _entityDefinition.resultMapper(e)).toList();
  }


}
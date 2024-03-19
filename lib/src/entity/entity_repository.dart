import 'package:loxia/src/drivers/driver.dart';
import 'package:loxia/src/entity/entity.dart';
import 'package:loxia/src/entity/entity_definition.dart';

class EntityRepository<E extends Entity>{

  late final EntityDefinition<E> _entityDefinition;
  late final Type entityType;
  late final Driver _driver;

  EntityRepository();

  void init(Driver driver, EntityDefinition<E> entityDefinition){
    _driver = driver;
    _entityDefinition = entityDefinition;
    print(entityDefinition.entity);
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
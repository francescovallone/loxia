import 'package:loxia/src/entity/entity.dart';

import '../drivers/driver.dart';

final class EntityRepository{

  final GeneratedEntity entity;
  final Type entityCls;
  late final Driver _driver;

  EntityRepository(this.entity, this.entityCls);

  void init(Driver driver){
    _driver = driver;
  }

  // Future<E> findById(dynamic id) async {
  //   // final result = await _driver.findById(id);
  //   // return _entityDefinition.resultMapper(result);
  //   return 
  // }

  Future<List<Entity>> query(String query) async {
    final result = await _driver.query(query);
    return result.map(entity.from).toList();
  }


}
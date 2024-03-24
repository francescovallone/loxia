import 'package:loxia/src/entity/entity.dart';
import 'package:loxia/src/queries/find/find_options.dart';

import '../drivers/driver.dart';

final class EntityRepository<T>{

  final GeneratedEntity entity;
  final Type entityCls;
  late final Driver _driver;

  EntityRepository(this.entity, this.entityCls);

  void init(Driver driver){
    _driver = driver;
  }

  factory EntityRepository.from(EntityRepository repository){
    final repo = EntityRepository<T>(repository.entity, repository.entityCls);
    repo.init(repository._driver);
    return repo;
  }

  // Future<E> findById(dynamic id) async {
  //   // final result = await _driver.findById(id);
  //   // return _entityDefinition.resultMapper(result);
  //   return 
  // }

  Future<List<T>> query(String query) async {
    final result = await _driver.query(query);
    return List<T>.from(result.map(entity.from));
  }

  Future<List<T>> find(FindOptions options) async {
    final result = await _driver.find(options, entity);
    print(result);
    return List<T>.from(result.map(entity.from));
  }


}
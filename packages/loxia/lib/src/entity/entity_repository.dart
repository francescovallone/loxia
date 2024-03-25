import 'package:loxia/src/entity/entity.dart';
import 'package:loxia/src/queries/find/find_options.dart';
import 'package:loxia/src/query_runner/query_runner.dart';

final class EntityRepository<T>{

  final GeneratedEntity entity;
  final Type entityCls;
  late final QueryRunner _queryRunner;

  EntityRepository(this.entity, this.entityCls);

  void init(QueryRunner queryRunner){
    _queryRunner = queryRunner;
  }

  factory EntityRepository.from(EntityRepository repository){
    final repo = EntityRepository<T>(repository.entity, repository.entityCls);
    repo.init(repository._queryRunner);
    return repo;
  }

  // Future<E> findById(dynamic id) async {
  //   // final result = await _driver.findById(id);
  //   // return _entityDefinition.resultMapper(result);
  //   return 
  // }

  Future<List<T>> query(String query) async {
    final result = await _queryRunner.query(query);
    return List<T>.from(result.map(entity.from));
  }

  Future<List<T>> find([FindOptions? options]) async {
    final result = await _queryRunner.find(options, entity);
    return List<T>.from(result.map(entity.from));
  }


}
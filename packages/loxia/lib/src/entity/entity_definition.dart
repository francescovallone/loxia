import 'entity_repository.dart';

final class EntityDefinition<E> {

  final Type entity;
  final E Function(Map<String, dynamic>) resultMapper;
  EntityRepository? repository = EntityRepository<E>();
  late final String tableName;

  EntityDefinition(
    this.entity, 
    this.resultMapper,
    {
      String? tableName
    }
  ): assert(entity == E, 'The parameter "entity" must be the same type as the generic type $E.') {
    tableName = tableName ?? entity.toString().toLowerCase();
  }

}
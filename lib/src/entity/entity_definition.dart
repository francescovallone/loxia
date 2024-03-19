import 'package:loxia/src/entity/entity.dart';
import 'package:loxia/src/entity/entity_repository.dart';

class EntityDefinition<E extends Entity> {

  final Type entity;
  final E Function(Map<String, dynamic>) resultMapper;
  final EntityRepository repository = EntityRepository<E>();
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
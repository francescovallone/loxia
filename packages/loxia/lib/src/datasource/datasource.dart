import 'options/datasource_options.dart';
import '../drivers/driver.dart';
import '../drivers/driver_factory.dart';
import '../entity/entity_definition.dart';
import '../entity/entity_repository.dart';

class DataSource<T extends DataSourceOptions>{

  final T options;
  late Driver _driver;

  Driver get driver => _driver;

  bool get isConnected => _driver.isConnected;

  Iterable<Type> get entities => options.entities.map((e) => e.entity);

  List<EntityRepository> _repositories = [];

  DataSource(this.options){
    _driver = DriverFactory().create<T>(this);
  }

  Future<void> init() async {
    if(isConnected){
      throw Exception('Connection already established');
    }
    await _driver.connect();
    _repositories.addAll(options.entities.map((e) => _generateRepository(e)));
  }

  EntityRepository<E> getRepository<E>() {
    print(_repositories);
    final repository = _repositories.where((e) => e.entityType == E);
    if(repository.isEmpty) {
      throw Exception('Repository for $E not found');
    }
    return repository.first as EntityRepository<E>;
  }

  Future<void> destroy() async {
    if(!isConnected){
      throw Exception('Connection already destroyed');
    }
    await _driver.dispose();
  }

  String escape(String value) => _driver.escape(value);

  _generateRepository(EntityDefinition entityDefinition) {
    entityDefinition.repository!.init(driver, entityDefinition);
    entityDefinition.repository = null;
    return entityDefinition.repository;
  }

}
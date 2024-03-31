import 'package:loxia/src/entity/entity.dart';

import 'options/datasource_options.dart';
import '../drivers/driver.dart';
import '../drivers/driver_factory.dart';
import '../entity/entity_repository.dart';

class DataSource<T extends DataSourceOptions> {
  final T options;
  late Driver _driver;

  Driver get driver => _driver;

  bool get isConnected => _driver.isConnected;

  Iterable<GeneratedEntity> get entities => options.entities.map((e) => e);

  final List<EntityRepository> _repositories = [];

  DataSource(this.options) {
    _driver = DriverFactory().create<T>(this);
  }

  Future<void> init() async {
    if (isConnected) {
      throw Exception('Connection already established');
    }
    await driver.connect();
    await driver.afterConnect();
    _repositories.addAll(options.entities.map((e) => _generateRepository(e)));
  }

  EntityRepository<E> getRepository<E>() {
    final repository = _repositories.where((e) => e.entity.entityCls == E);
    if (repository.isEmpty) {
      throw Exception('Repository for $E not found');
    }
    return EntityRepository<E>.from(repository.first);
  }

  Future<void> destroy() async {
    if (!isConnected) {
      throw Exception('Connection already destroyed');
    }
    await _driver.dispose();
  }

  String escape(String value) => _driver.escape(value);

  _generateRepository(GeneratedEntity entity) {
    EntityRepository repository = EntityRepository(entity, entity.entityCls);
    repository.init(_driver.queryRunner);
    return repository;
  }
}

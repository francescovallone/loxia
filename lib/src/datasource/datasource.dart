import 'package:loxia/src/datasource/options/datasource_options.dart';
import 'package:loxia/src/drivers/driver.dart';
import 'package:loxia/src/drivers/driver_factory.dart';
import 'package:loxia/src/entity/entity.dart';

class DataSource<T extends DataSourceOptions>{

  final T options;
  late Driver _driver;

  Driver get driver => _driver;

  bool get isConnected => _driver.isConnected;

  DataSource(this.options){
    _driver = DriverFactory().create<T>(this);
  }

  Future<void> init() async {
    if(isConnected){
      throw Exception('Connection already established');
    }
    await _driver.connect();
  }

  Future<void> destroy() async {
    if(!isConnected){
      throw Exception('Connection already destroyed');
    }
    await _driver.dispose();
  }

  String escape(String value) => _driver.escape(value);

  Future<List<E>> query<E extends Entity>(String query, E entity) async {
    return await _driver.query(query, entity);
  }

}
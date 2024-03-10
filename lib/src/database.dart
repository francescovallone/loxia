import 'drivers/driver.dart';
import 'drivers/options/driver_options.dart';
import 'drivers/postgres_driver.dart';
import 'enums/database_enum.dart';

class DatabaseConnection {

  late final Driver _driver;
  late DriverOptions _options;

  Driver get driver => _driver;
  DriverOptions get options => _options;

  DatabaseConnection();

  Future<void> init(DriverOptions options) async {
    switch(options.type){
      case DatabaseType.postgres:
        _driver = PostgresDriver();
        break;
      default:
        throw Exception('Database type not supported');
    }
    _options = options;
    await _driver.init(options); //
  }

}

class DatabaseOptions {
  
  final String name;
  final DriverOptions options;
  final List<Type> entities;

  DatabaseOptions({
    this.name = 'default',
    this.entities = const [],
    required this.options,
  }): assert(name.isNotEmpty && entities.every((element) => element.toString() == 'Entity'));
  
}

class Database {

  final Map<String, DatabaseConnection> _connections = {};

  static final Database _instance = Database._internal();

  DatabaseConnection get defaultConnection => _connections[_defaultDriverName]!;

  DatabaseConnection connection(String name) {
    if(!_connections.containsKey(name)) {
      throw Exception('Database connection with name $name does not exist');
    }
    return _connections[name]!;
  }

  String _defaultDriverName = 'default';

  Database._internal();

  factory Database() {
    return _instance;
  }

  Future<void> init({
    String defaultDriverName = 'default',
    required List<DatabaseOptions> config
  }) async {
    _defaultDriverName = defaultDriverName;
    for (var option in config) {
      if(_connections.containsKey(option.name)) {
        throw Exception('Database connection with name ${option.name} already exists');
      }
      final alreadyExists = _connections.values.any((element) => element.options.toString() == option.options.toString());
      if(alreadyExists) {
        throw Exception('Database connection with options ${option.options} already exists');
      }
      final connection = DatabaseConnection();
      await connection.init(option.options);
      _connections[option.name] = connection;
    }
  }

  Future<void> dispose() async {
    for (var connection in _connections.values) {
      await connection.driver.dispose();
    }
  }

}
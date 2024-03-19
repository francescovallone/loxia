
import 'package:loxia/src/datasource/datasource.dart';
import 'package:loxia/src/datasource/options/datasource_options.dart';
import 'package:loxia/src/entity/entity.dart';
import 'package:loxia/src/entity/entity_definition.dart';
import 'package:loxia/src/entity/entity_repository.dart';
import 'package:loxia/src/entity/primary_key.dart';

class User extends Entity {

  final String id;
  final String email;
  final String password;
  final String firstName;
  final String lastName;

  User({
    required this.id,
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    super.primaryKey = const PrimaryKeyString()
  });

  @override
  factory User.fromMap(Map<String, dynamic> values) {
    return User(
      id: values['id'],
      email: values['email'],
      password: values['password'],
      firstName: values['firstName'],
      lastName: values['lastName']
    );
  }
  
}

void main() async {
  final ed = EntityDefinition<User>(
          User,
          (values) => User.fromMap(values),
          tableName: 'users'
        );
  DataSource db = DataSource(
    PostgresDataSourceOptions(
      database: 'rupert',
      host: 'localhost',
      password: 'Rupert2@23!',
      port: 5432,
      username: 'rupert',
      entities: [
        ed
      ]
    )
  );

  await db.init();

  print("HELLO WORLD!");
  final repository = db.getRepository<User>();
  
  final users = await repository.query('SELECT * FROM "users"');
  final another = await (ed.repository as EntityRepository<User>).query('SELECT * FROM "users"');
  print(users.first.id);
  print(another.first.id);
  await db.destroy();

}
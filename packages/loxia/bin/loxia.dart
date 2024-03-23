
import 'package:loxia/loxia.dart';

import 'user_entity.dart';

void main() async {
  DataSource db = DataSource(
    PostgresDataSourceOptions(
      database: 'postgres',
      host: 'localhost',
      password: 'test_loxia',
      port: 5432,
      username: 'test_loxia',
      entities: [
        User.entity
      ]
    )
  );
  await db.init();
  final repository = db.getRepository<User>();

  final users = await repository.query('SELECT * FROM "user"');

  print(users);
  // print("HELLO WORLD!");
  // final repository = db.getRepository<User>();
  
  // final users = await repository.query('SELECT * FROM "users"');
  // final another = await (ed.repository as EntityRepository<User>).query('SELECT * FROM "users"');
  // print(users.first.id);
  // print(another.first.id);
  // await db.destroy();

}
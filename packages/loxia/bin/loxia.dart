
import 'package:loxia/loxia.dart';

import 'user_entity.dart';

void main() async {
  final ed = EntityDefinition<User>(
          User,
          (values) => User.fromMap(values),
          tableName: User.entity.table,
        );
  DataSource db = DataSource(
    PostgresDataSourceOptions(
      database: 'test_db',
      host: 'localhost',
      password: 'password',
      port: 5432,
      username: 'user',
      entities: [
        ed
      ]
    )
  );
  print(User.entity.table);
  // await db.init();

  // print("HELLO WORLD!");
  // final repository = db.getRepository<User>();
  
  // final users = await repository.query('SELECT * FROM "users"');
  // final another = await (ed.repository as EntityRepository<User>).query('SELECT * FROM "users"');
  // print(users.first.id);
  // print(another.first.id);
  // await db.destroy();

}
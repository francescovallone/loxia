
import 'package:loxia/loxia.dart';
import 'package:loxia/src/enums/order_by_enum.dart';
import 'package:loxia/src/queries/find/find_options.dart';

import 'todo_entity.dart';
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
        User.entity,
        Todo.entity
      ]
    )
  );
  await db.init();
  final repository = db.getRepository<User>();

  final users = await repository.query('SELECT * FROM "user"');
  print(users.first.firstName);
  final userFind = await repository.find(
    FindOptions(
      select: [
        'firstName',
        'lastName'
      ],
      where: [
        {
          'id': '2'
        },
        {
          'id': '1'
        }
      ],
      orderBy: {
        'id': OrderBy.asc
      }
    )
  );
  print(userFind.first.toString());
  final todo = db.getRepository<Todo>();
  final todos = await todo.query('SELECT * FROM "todo"');
  print(todos.firstOrNull);
  // print("HELLO WORLD!");
  // final repository = db.getRepository<User>();
  
  // final users = await repository.query('SELECT * FROM "users"');
  // final another = await (ed.repository as EntityRepository<User>).query('SELECT * FROM "users"');
  // print(users.first.id);
  // print(another.first.id);
  await db.destroy();

}
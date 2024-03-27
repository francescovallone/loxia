import 'package:loxia/loxia.dart';
import 'package:loxia/src/drivers/postgres/postgres_datasource_options.dart';
import 'package:loxia/src/enums/order_by_enum.dart';
import 'package:loxia/src/queries/find/find_options.dart';

import 'migration_test.dart';
import 'todo_entity.dart';
import 'user_entity.dart';

void main() async {
  DataSource db = DataSource(PostgresDataSourceOptions(
      database: 'postgres',
      host: 'localhost',
      password: 'test_loxia',
      port: 5432,
      username: 'test_loxia',
      entities: [User.entity, Todo.entity],
      migrations: [MigrationTest()]));
  await db.init();
  final repository = db.getRepository<User>();

  final users = await repository.query('SELECT * FROM "user"');
  print(users.firstOrNull?.firstName);
  final userFind = await repository.find(FindOptions(
      select: [], relations: {'todos': true}, orderBy: {'id': OrderBy.asc}));
  print(userFind.firstOrNull?.toString());
  print(userFind.first.todos);
  final todo = db.getRepository<Todo>();
  final todos = await todo.find();
  print(todos);
  // print("HELLO WORLD!");
  // final repository = db.getRepository<User>();

  // final users = await repository.query('SELECT * FROM "users"');
  // final another = await (ed.repository as EntityRepository<User>).query('SELECT * FROM "users"');
  // print(users.first.id);
  // print(another.first.id);
  await db.destroy();
}

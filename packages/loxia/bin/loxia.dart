import 'package:loxia/loxia.dart';
import 'package:loxia/src/drivers/sqlite/sqlite_datasource_options.dart';

import 'migration_test.dart';
import 'todo_entity.dart';
import 'user_entity.dart';

void main() async {
  // DataSource db = DataSource(PostgresDataSourceOptions(
  //     database: 'postgres',
  //     host: 'localhost',
  //     password: 'test_loxia',
  //     port: 5432,
  //     username: 'test_loxia',
  //     entities: [User.entity, Todo.entity],
  //     migrations: [MigrationTest()]));
  DataSource db = DataSource(SqliteDataSourceOptions(
      database: 'test.db',
      entities: [User.entity, Todo.entity],
      migrations: []));
  
  await db.init();
  final repository = db.getRepository<User>();
  print(repository);
  // final users = await repository.query('SELECT * FROM "user"');
  // print(users.firstOrNull?.firstName);
  // final userFind = await repository.find(FindOptions(
  //     select: [], relations: {'todos': true}, orderBy: {'id': OrderBy.asc}));
  // print(userFind.firstOrNull?.toString());
  // print(userFind.first.todos);
  // final todo = db.getRepository<Todo>();
  // final todos = await todo.find();
  // print(todos);
  print("HELLO WORLD!");
  // // final repository = db.getRepository<User>();

  // // final users = await repository.query('SELECT * FROM "users"');
  // // final another = await (ed.repository as EntityRepository<User>).query('SELECT * FROM "users"');
  // // print(users.first.id);
  // // print(another.first.id);
  await db.destroy();
}

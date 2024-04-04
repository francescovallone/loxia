import 'package:loxia/loxia.dart';
import 'package:loxia/src/drivers/sqlite/sqlite_datasource_options.dart';
import 'package:loxia/src/queries/find_options.dart';
import 'package:loxia/src/queries/operators/operators.dart';
import 'package:loxia/src/queries/where_clause.dart';

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
      migrations: [MigrationTest()]));

  await db.init();
  final repository = db.getRepository<Todo>();
  // final users = await repository.query('SELECT * FROM "user"');
  // print(users.firstOrNull?.firstName);
  // final userFind = await repository.find(FindOptions(
  //     select: [], relations: {'todos': true}, orderBy: {'id': OrderBy.asc}));
  // print(userFind.firstOrNull?.toString());
  // print(userFind.first.todos);
  // final todo = db.getRepository<Todo>();
  // final todos = await todo.find();
  // print(todos);
  final resultWithWhere = await repository.find(FindOptions(
      where: WhereClause(
        field: 'id',
        operator: Or([
          WhereClause(operator: Equal(1)),
          WhereClause(operator: Equal("2")),
          WhereClause(
            field: 'name',
            operator: Or([
              WhereClause(operator: Equal('Todo 1')),
              WhereClause(operator: Equal('Test2')),
            ]),
          ),
        ]),
      ),
      select: [],
      relations: {'user': true}));
  print(resultWithWhere.firstOrNull?.user);
  final resultWithCount = await repository.findAndCount(
      options: FindOptions(
          where: WhereClause(
            field: 'id',
            operator: Or([
              WhereClause(operator: Equal(1)),
              WhereClause(operator: Equal("2")),
              WhereClause(
                field: 'name',
                operator: Or([
                  WhereClause(operator: Equal('Todo 1')),
                  WhereClause(operator: Equal('Test2')),
                ]),
              ),
            ]),
          ),
          select: [],
          relations: {'user': true}),
      distinct: false);
  print(resultWithCount.results.firstOrNull?.user);
  // // final repository = db.getRepository<User>();

  // // final users = await repository.query('SELECT * FROM "users"');
  // // final another = await (ed.repository as EntityRepository<User>).query('SELECT * FROM "users"');
  // // print(users.first.id);
  // // print(another.first.id);
  await db.destroy();
}

import 'migration_test.dart';
import 'todo_entity.dart';
import 'user_entity.dart';
import 'package:loxia/loxia.dart';

void main() async {
  DataSource db = DataSource(SqliteDataSourceOptions(
      database: 'test.db',
      entities: [User.entity, Todo.entity],
      migrations: [MigrationTest()]));
  
  await db.init();
  final repository = db.getRepository<Todo>();
  final resultWithWhere = await repository.find(
    FindOptions(
      where: WhereClause(
        field: 'id',
        operator: Or([
          WhereClause(operator: Equal(1)),
          WhereClause(operator: Equal("2")),
          WhereClause(field: 'name', operator: Or([
            WhereClause(operator: Equal('Todo 1')),
            WhereClause(operator: Equal('Test2')),
          ]),),
        ]),
      ),
      select: [],
      relations: {
        'user': true
      }
    )
  );
  print(resultWithWhere.firstOrNull?.user);
  final resultWithCount = await repository.findAndCount(
    options: FindOptions(
      where: WhereClause(
        field: 'id',
        operator: Or([
          WhereClause(operator: Equal(1)),
          WhereClause(operator: Equal("2")),
          WhereClause(field: 'name', operator: Or([
            WhereClause(operator: Equal('Todo 1')),
            WhereClause(operator: Equal('Test2')),
          ]),),
        ]),
      ),
      select: [],
      relations: {
        'user': true
      }
    ),
    distinct: false
  );
  print(resultWithCount.results.firstOrNull?.user);
  await db.destroy();
}

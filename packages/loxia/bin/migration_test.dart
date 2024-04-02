import 'package:loxia/src/metadata/column_metadata.dart';
import 'package:loxia/src/migrations/migration.dart';
import 'package:loxia/src/query_runner/query_runner.dart';

class MigrationTest extends Migration {

  @override
  int get version => 2;

  @override
  Future<void> down(QueryRunner queryRunner) async {}

  @override
  Future<void> up(QueryRunner queryRunner) async {
    queryRunner.addColumn('todo', 
      ColumnMetadata(name: 'views', type: 'int', defaultValue: 0)
    );
  }
}

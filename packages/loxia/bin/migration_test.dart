import 'package:loxia/src/migrations/migration.dart';
import 'package:loxia/src/query_runner/query_runner.dart';

class MigrationTest extends Migration {
  @override
  Future<void> down(QueryRunner queryRunner) async {
    queryRunner.query('ALTER TABLE "user" DROP COLUMN age;');
  }

  @override
  Future<void> up(QueryRunner queryRunner) async {
    queryRunner.query('ALTER TABLE "user" ADD COLUMN age INT;');
  }
}

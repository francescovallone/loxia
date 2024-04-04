import 'package:loxia/src/query_runner/query_runner.dart';

abstract class Migration {
  /// This parameter should only be used for sqlite databases
  /// to keep track of the current version of the database
  /// schema.
  /// In other databases, this parameter should be ignored.
  int get version => 1;

  /// This method should contain the queries to be executed
  /// when the migration is applied.
  Future<void> up(QueryRunner queryRunner);

  /// This method should contain the queries to be executed
  /// when the migration is rolled back.
  Future<void> down(QueryRunner queryRunner);
}

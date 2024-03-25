import 'package:loxia/src/query_runner/query_runner.dart';

abstract class Migration {

  Future<void> up(QueryRunner queryRunner);

  Future<void> down(QueryRunner queryRunner);

}

import 'package:loxia/src/database.dart';
import 'package:loxia/src/drivers/options/driver_options.dart';
import 'package:loxia/src/drivers/postgres_driver.dart';

void main() async {

  Database db = Database();

  await db.init(
    config: [
      DatabaseOptions(
        options: PostgresDriverOptions(
          host: 'localhost',
          port: 5432,
          database: 'rupert',
          username: 'rupert',
          password: 'Rupert2@23!'
        )
      ),
    ]
  );

  final df = db.defaultConnection;
  

  await db.dispose();

}
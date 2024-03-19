
import 'package:loxia/src/datasource/datasource.dart';
import 'package:loxia/src/datasource/options/datasource_options.dart';
import 'package:loxia/src/entity/entity.dart';
import 'package:loxia/src/entity/primary_key.dart';

class User extends Entity {
  User() : super(
    primaryKey: PrimaryKeyString(),
    tableName: 'user'
  );

  late String id;
  late String businessUnit;
  late String company;
  late String? notificationsToken;
  
  @override
  User fromResultSet(Map<String, dynamic> resultSet) {
    id = resultSet['id'];
    businessUnit = resultSet['businessUnit'];
    company = resultSet['company'];
    notificationsToken = resultSet['notificationsToken'];
    return this;
  }
  
  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'businessUnit': businessUnit,
      'company': company,
      'notificationsToken': notificationsToken
    };
  }
  
}

void main() async {

  DataSource db = DataSource(
    PostgresDataSourceOptions(
      database: 'orbyta',
      host: 'localhost',
      password: 'orbyta',
      port: 5432,
      username: 'orbyta'
    )
  );

  await db.init();

  print("HELLO WORLD!");
  final result = await db.query('SELECT * FROM "user"', User());
  print(result.map((e) => e.hashCode));

  await db.destroy();

}
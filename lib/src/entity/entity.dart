import 'primary_key.dart';

abstract class Entity {

  final PrimaryKey primaryKey;
  late final String tableName;

  Entity({
    required this.primaryKey,
    String? tableName,
  }){
    this.tableName = tableName ?? runtimeType.toString().toLowerCase();
  }
  
  factory Entity.fromResultSet(Map<String, dynamic> resultSet){
    throw UnimplementedError();
  }

  Map<String, dynamic> toMap();

}
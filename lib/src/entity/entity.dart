import 'primary_key.dart';

abstract class Entity {

  final PrimaryKey primaryKey;

  Entity({
    required this.primaryKey,
  });

  factory Entity.fromMap(Map<String, dynamic> values) => throw UnimplementedError();

}
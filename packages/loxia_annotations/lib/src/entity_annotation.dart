import 'package:meta/meta.dart';
import 'package:meta/meta_meta.dart';

/// The [Entity] annotation is used to define a class as an entity.
/// 
/// An entity is a class that represents a table in the database.
/// 
/// Example:
/// 
/// ```dart
/// @Entity()
/// class User extends Entity {}
/// ```
@sealed
@Target({TargetKind.classType})
class Entity{

  /// If the table name is not provided, the class name will be used as the table name
  /// 
  /// Example:
  /// 
  /// ```dart
  /// @Entity()
  /// class User extends Entity {}
  /// 
  /// // The table name will be "user"
  /// 
  /// @Entity(table: "users")
  /// class User extends Entity {}
  /// // The table name will be "users"
  /// ```
  final String? table;
  
  const Entity({
    this.table,
  });
  
}
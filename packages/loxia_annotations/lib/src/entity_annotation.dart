import 'package:meta/meta.dart';
import 'package:meta/meta_meta.dart';

/// The [EntityMeta] annotation is used to define a class as an entity.
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
class EntityMeta {
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

  /// If the schema name is not provided, Loxia will use the default schema name
  final String? schema;

  const EntityMeta({
    this.table,
    this.schema,
  });
}

import 'package:meta/meta.dart';
import 'package:meta/meta_meta.dart';


/// The [Column] annotation is used to define a field as a column in the database.
/// 
/// Example:
/// 
/// ```dart
/// @Entity()
/// class User extends Entity {
/// 
///  @Column()
/// final String? name;
/// 
/// }
/// ```
/// 
/// The column name will be the same as the field name if the name is not provided.
@sealed
@Target({TargetKind.field})
class Column{
  
  final String? name;
  final String? explicitType;
  final dynamic defaultValue;
  final bool unique;
  
  const Column({
    this.name,
    this.explicitType,
    this.defaultValue,
    this.unique = false,
  });

}


class PrimaryKey extends Column{
  
  final bool autoIncrement;
  final bool uuid;

  @override
  bool get unique => true;
  
  const PrimaryKey({
    super.name,
    this.autoIncrement = false,
    this.uuid = false,
  });

}
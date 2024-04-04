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
class Column {
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

class PrimaryKey extends Column {
  final bool autoIncrement;
  final bool uuid;

  @override
  bool get unique => true;

  const PrimaryKey({
    super.name,
    this.autoIncrement = false,
    this.uuid = false,
  }) : assert(autoIncrement == false || uuid == false,
            'autoIncrement and uuid cannot be true at the same time');
}

@sealed
@Target({TargetKind.field})
abstract class Relation {
  final Type on;
  final String referenceColumn;

  const Relation({
    required this.on,
    this.referenceColumn = 'id',
  });
}

class OneToOne extends Relation {
  final bool joinColumn;

  const OneToOne({
    required super.on,
    super.referenceColumn,
    this.joinColumn = false,
  });
}

class OneToMany extends Relation {
  const OneToMany({
    required super.on,
    super.referenceColumn,
  });
}

class ManyToOne extends Relation {
  const ManyToOne({
    required super.on,
    super.referenceColumn,
  });
}

class ManyToMany extends Relation {
  final bool joinTable;

  const ManyToMany({
    required super.on,
    super.referenceColumn,
    this.joinTable = false,
  });
}

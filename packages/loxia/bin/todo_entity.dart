import 'package:loxia/src/entity/entity.dart';
import 'package:loxia/src/entity/entity_schema.dart';
import 'package:loxia/src/entity/table.dart';
import 'package:loxia/src/enums/relation_type_enum.dart';
import 'package:loxia/src/metadata/column_metadata.dart';
import 'package:loxia/src/metadata/relation_metadata.dart';
import 'package:loxia_annotations/loxia_annotations.dart';

import 'user_entity.dart';

part 'todo_entity.g.dart';

@EntityMeta()
class Todo extends Entity {
  static TodoEntity get entity => TodoEntity();

  @PrimaryKey(autoIncrement: true)
  int id;

  @Column(defaultValue: 'todo', unique: true)
  String name;

  @Column(defaultValue: false)
  bool isDone;

  @Column()
  String? description;

  @Column(
    defaultValue: 'CURRENT_TIMESTAMP'
  )
  DateTime createdAt;

  @ManyToOne(on: User)
  User? user;

  Todo(
      {required this.id,
      required this.name,
      required this.isDone,
      required this.createdAt,
      this.description,
      this.user});
}

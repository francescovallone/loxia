import 'package:loxia/src/entity/entity.dart';
import 'package:loxia/src/entity/entity_schema.dart';
import 'package:loxia/src/enums/relation_type_enum.dart';
import 'package:loxia_annotations/loxia_annotations.dart';

import 'user_entity.dart';

part 'todo_entity.g.dart';

@EntityMeta()
class Todo extends Entity{

  static TodoEntity get entity => TodoEntity();

  @PrimaryKey(
    uuid: true
  )
  final String id;

  @Column(
    defaultValue: 'todo',
    unique: true
  )
  final String name;

  @Column(
    defaultValue: false
  )
  final bool isDone;


  @Column()
  final String? description;

  @ManyToOne(
    on: User
  )
  final User user;

  Todo({
    required this.id,
    required this.name,
    required this.isDone,
    this.description,
    required this.user,
  });
  
}
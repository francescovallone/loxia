import 'package:loxia/loxia.dart';

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

  @ManyToOne(on: User)
  User? user;

  Todo({
    required this.id,
    required this.name,
    required this.isDone,
    this.description,
    this.user
  });
}

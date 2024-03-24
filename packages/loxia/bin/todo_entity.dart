import 'package:loxia/loxia.dart';
import 'package:loxia/src/entity/entity.dart';
import 'package:loxia_annotations/loxia_annotations.dart';

part 'todo_entity.g.dart';

@EntityMeta()
class Todo extends Entity{

  static TodoEntity get entity => TodoEntity();

  @PrimaryKey(
    uuid: true
  )
  final String id;
  @Column()
  final String name;
  @Column()
  final bool isDone;

  Todo({
    required this.id,
    required this.name,
    required this.isDone,
  });
  
}
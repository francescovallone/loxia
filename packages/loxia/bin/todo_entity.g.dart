// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_entity.dart';

// **************************************************************************
// LoxiaGenerator
// **************************************************************************

class TodoEntity extends GeneratedEntity {
  @override
  final String table = 'todo';

  @override
  final Type entityCls = Todo;

  @override
  final EntitySchema schema = EntitySchema([
    FieldSchema(
      name: 'id',
      type: 'String',
      nullable: false,
      primaryKey: true,
      autoIncrement: false,
      uuid: true,
    ),
    FieldSchema(
      name: 'name',
      type: 'String',
      nullable: false,
      unique: true,
      defaultValue: 'todo',
    ),
    FieldSchema(
      name: 'isDone',
      type: 'bool',
      nullable: false,
      unique: false,
      defaultValue: false,
    ),
    FieldSchema(
      name: 'description',
      type: 'String',
      nullable: true,
      unique: false,
      defaultValue: null,
    ),
  ]);

  @override
  Todo from(Map<String, dynamic> map) {
    return Todo(
        id: map.containsKey("id") ? map['id'] : '',
        name: map.containsKey("name") ? map['name'] : 'todo',
        isDone: map.containsKey("isDone") ? map['isDone'] : false,
        description:
            map.containsKey("description") ? map['description'] : null);
  }

  @override
  Map<String, dynamic> to(Todo entity) {
    return {
      'id': entity.id,
      'name': entity.name,
      'isDone': entity.isDone,
      'description': entity.description
    };
  }
}

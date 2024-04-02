// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_entity.dart';

// **************************************************************************
// LoxiaGenerator
// **************************************************************************

class TodoEntity extends GeneratedEntity {
  @override
  Type get entityCls => Todo;

  @override
  final Schema schema = Schema(
    table: Table(
      name: 'todo',
      columns: [
        ColumnMetadata(
          name: 'id',
          type: 'int',
          explicitType: null,
          nullable: false,
          primaryKey: true,
          unique: false,
          defaultValue: null,
          autoIncrement: true,
        ),
        ColumnMetadata(
          name: 'name',
          type: 'String',
          explicitType: null,
          nullable: false,
          primaryKey: false,
          unique: true,
          defaultValue: 'todo',
        ),
        ColumnMetadata(
          name: 'isDone',
          type: 'bool',
          explicitType: null,
          nullable: false,
          primaryKey: false,
          unique: false,
          defaultValue: false,
        ),
        ColumnMetadata(
          name: 'description',
          type: 'String',
          explicitType: null,
          nullable: true,
          primaryKey: false,
          unique: false,
          defaultValue: null,
        ),
      ],
    ),
  );

  @override
  Todo from(Map<String, dynamic> map) {
    return Todo(
      id: map.containsKey("id") ? map['id'] : '',
      name: map.containsKey("name") ? map['name'] : 'todo',
      isDone: map.containsKey("isDone") ? map['isDone'] : false,
      description: map.containsKey("description") ? map['description'] : null,
    );
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

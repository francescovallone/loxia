// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_entity.dart';

// **************************************************************************
// LoxiaGenerator
// **************************************************************************

final generatedSchema = Schema(
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
      ColumnMetadata(
        name: 'createdAt',
        type: 'DateTime',
        explicitType: null,
        nullable: false,
        primaryKey: false,
        unique: false,
        defaultValue: 'CURRENT_TIMESTAMP',
      ),
    ],
    relations: [
      RelationMetadata(
        column: 'user',
        entity: UserEntity,
        inverseEntity: TodoEntity,
        type: RelationType.manyToOne,
      ),
    ],
  ),
);

class TodoEntity extends GeneratedEntity {
  @override
  Type get entityCls => Todo;

  @override
  final Schema schema = generatedSchema;

  @override
  Todo from(Map<String, dynamic> map) {
    return Todo(
        id: map.containsKey("id") ? map['id'] : -1,
        name: map.containsKey("name") ? map['name'] : 'todo',
        isDone: map.containsKey("isDone") ? map['isDone'] : false,
        description: map.containsKey("description") ? map['description'] : null,
        createdAt: map.containsKey("createdAt") ? map['createdAt'] : null,
        user: map.containsKey('user') && map['user'] is Map<String, dynamic>
            ? User.entity.from(map['user'])
            : null);
  }

  @override
  Map<String, dynamic> to(Todo entity) {
    return {
      'id': entity.id,
      'name': entity.name,
      'isDone': entity.isDone,
      'description': entity.description,
      'createdAt': entity.createdAt,
      'user': entity.user != null ? User.entity.to(entity.user!) : null
    }..removeWhere((key, value) => value == null);
  }
}

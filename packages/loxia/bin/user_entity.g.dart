// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_entity.dart';

// **************************************************************************
// LoxiaGenerator
// **************************************************************************

final generatedSchema = Schema(
  table: Table(
    name: 'user',
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
        name: 'email',
        type: 'String',
        explicitType: null,
        nullable: false,
        primaryKey: false,
        unique: false,
        defaultValue: null,
      ),
      ColumnMetadata(
        name: 'password',
        type: 'String',
        explicitType: null,
        nullable: false,
        primaryKey: false,
        unique: false,
        defaultValue: null,
      ),
      ColumnMetadata(
        name: 'firstName',
        type: 'String',
        explicitType: null,
        nullable: false,
        primaryKey: false,
        unique: false,
        defaultValue: null,
      ),
      ColumnMetadata(
        name: 'lastName',
        type: 'String',
        explicitType: null,
        nullable: false,
        primaryKey: false,
        unique: false,
        defaultValue: null,
      ),
    ],
    relations: [
      RelationMetadata(
        column: 'todos',
        entity: TodoEntity,
        inverseEntity: UserEntity,
        type: RelationType.oneToMany,
      ),
    ],
  ),
);

class UserEntity extends GeneratedEntity {
  @override
  Type get entityCls => User;

  @override
  final Schema schema = generatedSchema;

  @override
  User from(Map<String, dynamic> map) {
    return User(
        id: map.containsKey("id") ? map['id'] : null,
        email: map.containsKey("email") ? map['email'] : null,
        password: map.containsKey("password") ? map['password'] : null,
        firstName: map.containsKey("firstName") ? map['firstName'] : null,
        lastName: map.containsKey("lastName") ? map['lastName'] : null,
        todos: map.containsKey('todos') &&
                map['todos'] is List<Map<String, dynamic>>
            ? map['todos'].map(User.entity.from)
            : []);
  }

  @override
  Map<String, dynamic> to(User entity) {
    return {
      'id': entity.id,
      'email': entity.email,
      'password': entity.password,
      'firstName': entity.firstName,
      'lastName': entity.lastName,
      'todos': entity.todos.map(Todo.entity.to).toList()
    };
  }
}

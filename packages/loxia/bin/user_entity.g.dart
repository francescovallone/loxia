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

class PartialUser extends PartialEntity {
  int? id;
  String? email;
  String? password;
  String? firstName;
  String? lastName;
  List<Todo>? todos;

  @override
  bool isPartial() {
    return id == null ||
        email == null ||
        password == null ||
        firstName == null ||
        lastName == null ||
        todos == null;
  }

  @override
  Map<String, dynamic> to(PartialUser entity) {
    return {
      'id': entity.id,
      'email': entity.email,
      'password': entity.password,
      'firstName': entity.firstName,
      'lastName': entity.lastName,
      'todos': entity.todos
    };
  }

  @override
  PartialUser from(Map<String, dynamic> values) {
    return PartialUser(
        id: values.containsKey('id') ? values['id'] : null,
        email: values.containsKey('email') ? values['email'] : null,
        password: values.containsKey('password') ? values['password'] : null,
        firstName: values.containsKey('firstName') ? values['firstName'] : null,
        lastName: values.containsKey('lastName') ? values['lastName'] : null,
        todos: values.containsKey('todos') ? values['todos'] : null);
  }

  PartialUser({
    this.id,
    this.email,
    this.password,
    this.firstName,
    this.lastName,
    this.todos,
  });

  @override
  User toEntity() {
    if (isPartial()) {
      throw Exception('Cannot convert partial entity to entity');
    }
    return User(
        id: id!,
        email: email!,
        password: password!,
        firstName: firstName!,
        lastName: lastName!,
        todos: todos ?? const []);
  }
}

class UserEntity extends GeneratedEntity {
  @override
  Type get entityCls => User;

  @override
  final Schema schema = generatedSchema;

  @override
  final PartialEntity partialEntity = PartialUser();

  @override
  User from(Map<String, dynamic> map) {
    return User(
        id: map.containsKey("id") ? map['id'] : -1,
        email: map.containsKey("email") ? map['email'] : '',
        password: map.containsKey("password") ? map['password'] : '',
        firstName: map.containsKey("firstName") ? map['firstName'] : '',
        lastName: map.containsKey("lastName") ? map['lastName'] : '',
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
    }..removeWhere((key, value) => value == null);
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_entity.dart';

// **************************************************************************
// LoxiaGenerator
// **************************************************************************

class UserEntity extends GeneratedEntity {
  @override
  final Table table = Table('user');

  @override
  final Type entityCls = User;

  factory UserEntity() => _instance;

  UserEntity._();

  static final UserEntity _instance = UserEntity._();

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
      name: 'email',
      type: 'String',
      nullable: false,
      unique: false,
    ),
    FieldSchema(
      name: 'password',
      type: 'String',
      nullable: false,
      unique: false,
    ),
    FieldSchema(
      name: 'firstName',
      type: 'String',
      nullable: false,
      unique: false,
    ),
    FieldSchema(
      name: 'lastName',
      type: 'String',
      nullable: false,
      unique: false,
    ),
    FieldSchema(
      name: 'todos',
      type: 'String',
      nullable: false,
      unique: false,
      relationType: RelationType.oneToMany,
      relationEntity: Todo,
    ),
  ]);

  @override
  User from(Map<String, dynamic> map) {
    print(map);
    return User(
        id: map.containsKey("id") ? map['id'] : '',
        email: map.containsKey("email") ? map['email'] : '',
        password: map.containsKey("password") ? map['password'] : '',
        firstName: map.containsKey("firstName") ? map['firstName'] : '',
        lastName: map.containsKey("lastName") ? map['lastName'] : '',
        todos: List<Map<String, dynamic>>.from(map['todos'] ?? []).map(Todo.entity.from).toList()
        );
  }

  @override
  Map<String, dynamic> to(User entity) {
    return {
      'id': entity.id,
      'email': entity.email,
      'password': entity.password,
      'firstName': entity.firstName,
      'lastName': entity.lastName,
      'todos': entity.todos
    };
  }
}

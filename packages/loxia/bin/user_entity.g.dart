// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_entity.dart';

// **************************************************************************
// LoxiaGenerator
// **************************************************************************

class UserEntity extends GeneratedEntity {
  @override
  final String table = 'user';

  @override
  final Type entityCls = User;

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
    ),
    FieldSchema(
      name: 'password',
      type: 'String',
      nullable: false,
    ),
    FieldSchema(
      name: 'firstName',
      type: 'String',
      nullable: false,
    ),
    FieldSchema(
      name: 'lastName',
      type: 'String',
      nullable: false,
    ),
  ]);

  @override
  User from(Map<String, dynamic> map) {
    return User(
        id: map.containsKey("id") ? map['id'] : "",
        email: map.containsKey("email") ? map['email'] : "",
        password: map.containsKey("password") ? map['password'] : "",
        firstName: map.containsKey("firstName") ? map['firstName'] : "",
        lastName: map.containsKey("lastName") ? map['lastName'] : "");
  }

  @override
  Map<String, dynamic> to(User entity) {
    return {
      'id': entity.id,
      'email': entity.email,
      'password': entity.password,
      'firstName': entity.firstName,
      'lastName': entity.lastName
    };
  }
}

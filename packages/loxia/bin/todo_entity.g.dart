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

class PartialTodo extends PartialEntity {
  int? id;
  String? name;
  bool? isDone;
  String? description;
  DateTime? createdAt;
  User? user;

  @override
  bool isPartial() {
    return id == null || name == null || isDone == null || createdAt == null;
  }

  @override
  Map<String, dynamic> to(PartialTodo entity) {
    return {
      'id': entity.id,
      'name': entity.name,
      'isDone': entity.isDone,
      'description': entity.description,
      'createdAt': entity.createdAt,
      'user': entity.user
    };
  }

  @override
  PartialTodo from(Map<String, dynamic> values) {
    return PartialTodo(
        id: values.containsKey('id') ? values['id'] : null,
        name: values.containsKey('name') ? values['name'] : null,
        isDone: values.containsKey('isDone') ? values['isDone'] : null,
        description:
            values.containsKey('description') ? values['description'] : null,
        createdAt: values.containsKey('createdAt') ? values['createdAt'] : null,
        user: values.containsKey('user') ? values['user'] : null);
  }

  PartialTodo({
    this.id,
    this.name,
    this.isDone,
    this.description,
    this.createdAt,
    this.user,
  });

  @override
  Todo toEntity() {
    if (isPartial()) {
      throw Exception('Cannot convert partial entity to entity');
    }
    return Todo(
        id: id!,
        name: name!,
        isDone: isDone!,
        createdAt: createdAt!,
        description: description,
        user: user);
  }
}

class TodoEntity extends GeneratedEntity {
  @override
  Type get entityCls => Todo;

  @override
  final Schema schema = generatedSchema;

  @override
  final PartialEntity partialEntity = PartialTodo();

  @override
  Todo from(Map<String, dynamic> map) {
    return Todo(
        id: map.containsKey("id") ? map['id'] : -1,
        name: map.containsKey("name") ? map['name'] : 'todo',
        isDone: map.containsKey("isDone") ? map['isDone'] : false,
        description: map.containsKey("description") ? map['description'] : null,
        createdAt:
            map.containsKey("createdAt") ? map['createdAt'] : DateTime.now(),
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

# Relations

## OneToOne

The `@OneToOne` annotation is used to define a one-to-one relationship between two entities.

### Properties

- `joinColumn`: If this entity is the owner of the relationship.

```dart

import 'package:loxia/loxia.dart';

@EntityMeta()
class User extends Entity {
  
  static UserEntity get entity => UserEntity();

  @Column()
  String name;

  @OneToOne()
  Address address;
}

@EntityMeta()
class Address extends Entity {
  
  static AddressEntity get entity => AddressEntity();

  @Column()
  String street;

  @Column()
  String city;

  @OneToOne()
  User user;
}
```

In this example, the `User` and `Address` classes have a one-to-one relationship. The `User` class has an `address` field that is annotated with `@OneToOne`. The `Address` class has a `user` field that is annotated with `@OneToOne`.

## OneToMany & ManyToOne

The `@OneToMany` annotation is used to define a one-to-many relationship between two entities.

### Properties

- `on`: The entity class that the relationship is on.
- `referenceColumn`: The column that the relationship is on. If not provided, the first primary key column of the entity class is used.

```dart

import 'package:loxia/loxia.dart';

@EntityMeta()
class User extends Entity {
  
  static UserEntity get entity => UserEntity();

  @Column()
  String name;

  @OneToMany(
    on: Post
  )
  List<Post> posts;
}

@EntityMeta()
class Post extends Entity {
  
  static PostEntity get entity => PostEntity();

  @Column()
  String title;

  @Column()
  String content;

  @ManyToOne(
    on: User
  )
  User user;
}
```

In this example, the `User` and `Post` classes have a one-to-many relationship. The `User` class has a `posts` field that is annotated with `@OneToMany`. The `Post` class has a `user` field that is annotated with `@ManyToOne`.

## ManyToMany

The `@ManyToMany` annotation is used to define a many-to-many relationship between two entities.

### Properties

- `joinTable`: If the relationship is defined by a join table.

```dart

import 'package:loxia/loxia.dart';

@EntityMeta()
class User extends Entity {
  
  static UserEntity get entity => UserEntity();

  @Column()
  String name;

  @ManyToMany()
  List<Role> roles;
}

@EntityMeta()
class Role extends Entity {
  
  static RoleEntity get entity => RoleEntity();

  @Column()
  String name;

  @ManyToMany()
  List<User> users;
}
```

In this example, the `User` and `Role` classes have a many-to-many relationship. The `User` class has a `roles` field that is annotated with `@ManyToMany`. The `Role` class has a `users` field that is annotated with `@ManyToMany`.

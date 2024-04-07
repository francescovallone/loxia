# Entity

Loxia uses entities to represent the tables in the database. To define an entity, you need to create a class that extends `Entity` and annotate it with `@EntityMeta`.

```dart

import 'package:loxia/loxia.dart';

@EntityMeta()
class User extends Entity {
  
  static UserEntity get entity => UserEntity();

  @Column()
  String name;

  @Column()
  int age;
}

```

The `@EntityMeta` annotation is used to generate the necessary code to interact with the database.

Inside the annotation you can pass the following parameters:

- `table`: The name of the table in the database. If not provided, the name of the class will be used.
- `schema`: The name of the schema in the database. If not provided, the default schema will be used.

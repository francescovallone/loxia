# Column

Loxia uses the `@Column` annotation to define the columns in the database table.

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

The `@Column` annotation has the following parameters:

- `name`: The name of the column in the database. If not provided, the name of the field will be used.
- `type`: The type of the column in the database. If not provided, the type will be inferred from the field type.
- `explicitType`: The explicit type of the column in the database. This is useful when the type cannot be inferred from the field type or when you want to use a different type in the database.
- `defaultValue`: The default value of the column in the database. If not provided, the column will not have a default value.
- `unique`: A flag that indicates if the values of the column are unique in the database. If not provided, the column will not be unique.

## Nullability

The nullability of a column is inferred from the field type. If the field type is nullable, the column will be nullable in the database. If the field type is not nullable, the column will not be nullable in the database.

```dart
import 'package:loxia/loxia.dart';

@EntityMeta()
class User extends Entity {
  
  static UserEntity get entity => UserEntity();

  @Column()
  String? name;

  @Column()
  int age;
}
```

In this example, the `name` column will be nullable in the database because the `name` field is nullable in the class.

## Primary Key

::: warning
The field annotated with `@PrimaryKey` must be of type `int` or `String`.
:::

To define a primary key column, you can use the `@PrimaryKey` annotation.

```dart
import 'package:loxia/loxia.dart';

@EntityMeta()
class User extends Entity {
  
  static UserEntity get entity => UserEntity();

  @PrimaryKey()
  int id;

  @Column()
  String name;

  @Column()
  int age;
}
```

In this example, the `id` column will be the primary key of the table.

The `@PrimaryKey` annotation has the following parameters:

- `autoIncrement`: A flag that indicates if the primary key column is auto-increment. If not provided, the primary key column will not be auto-increment.
- `uuid`: A flag that indicates if the primary key column is a UUID. If not provided, the primary key column will not be a UUID.

::: warning
The `autoIncrement` and `uuid` parameters are mutually exclusive. You can only use one of them.
:::

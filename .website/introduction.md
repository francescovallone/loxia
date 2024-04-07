# Introduction

Loxia is a simple ORM for Dart. It is inspired by [TypeORM](https://typeorm.io/) and it is designed to be easy to use and to integrate with your existing projects.

## Features

- **Type-safe**: Loxia uses code generation to ensure type safety.

- **Easy to use**: Loxia is designed to be easy to use and to integrate with your existing projects.

- **Supports multiple databases**: Loxia will supports multiple databases out of the box.

- **Code generation**: Loxia uses code generation to generate the necessary code to interact with the database.

## Getting started

To get started with Loxia, you need to add the following dependencies to your `pubspec.yaml` file:

```yaml
dependencies:
  loxia: ^0.1.0

dev_dependencies:
  loxia_generator: ^0.1.0
  build_runner: ^2.0.0
```

### Defining entities

Then, you need to create a class that extends `Entity` and annotate it with `@EntityMeta`.

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

Finally, you need to run the following command to generate the necessary code:

```bash
dart run build_runner build watch
```

### Create the datasource

To create a datasource, you just need to instantiate the `DataSource` class and pass the database connection options.

```dart

final dataSource = DataSource(
  SqliteDataSourceOptions(
    database: 'test.db',
    entities: [User.entity],
  )
);

await dataSource.connect();

```

### Getting the repository

Loxia uses repositories to interact with the database. To get a repository, you just need to call the `getRepository` method on the `DataSource` instance.

```dart

final userRepository = dataSource.getRepository<User>();

```

As you can see the repository is type-safe and will try to map the results of the queries to the `User` class.

### Inserting data

To insert data into the database, you just need to call the `insert` method on the repository.

```dart

final user = User()
  ..name = 'John Doe'
  ..age = 30;

final newId = await userRepository.insert(User.entity.to(user));

```

### Querying data

To query data from the database, you just need to call the `find` method on the repository.

```dart

// Find all users inside the use
final users = await userRepository.find();

```

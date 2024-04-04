# Loxia

Loxia is a Dart ORM library that aims to be fully-featured, easy-to-use, and flexible to manage entities and relations in your server-side applications.

> **This library is still in development and is not ready for production use. Use it at your own risk.**

## Installation

```bash
dart pub add loxia
```

## Usage

```dart
import 'package:loxia/loxia.dart';

Future<void> main() async {
  	DataSource db = DataSource(
		SqliteDataSourceOptions(
			database: 'test.db',
			entities: [User.entity, Todo.entity],
			migrations: []
		)
	);

	await db.init();
	final repository = db.getRepository<Todo>();

	final newTodo = Todo(
		title: 'Test',
		description: 'Test description',
	);

	await repository.insert(Todo.entity.to(newTodo));

	final todos = await repository.find();

	print(todos);

	await db.close();
}
```
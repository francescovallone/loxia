# Find Query

To query data from the database, you just need to call the `find` method on the repository.

```dart

// Find all users inside the use
final users = await userRepository.find();
```

The `find` method has the following parameters:

- `where`: A `WhereClause` object that represents the conditions of the query.
- `orderBy`: A list of `OrderBy` objects that represents the order of the query.
- `limit`: The maximum number of rows to return.
- `offset`: The number of rows to skip before starting to return rows.
- `select`: A list of columns to select.
- `relations`: A Map of relations to include in the query.

```dart

// Find all users with the name 'John Doe'
final users = await userRepository.find(
  where: WhereClause(
	field: name,
	operator: Equal('John Doe'),
  )
);

// Find all users with the name 'John Doe' and age greater than 30

final users = await userRepository.find(
  where: WhereClause(
	operator: And([
		WhereClause(
			field: name,
			operator: Equal('John Doe'),
		),
		WhereClause(
			field: age,
			operator: GreaterThan(30),
		)
	])
  )
);
```
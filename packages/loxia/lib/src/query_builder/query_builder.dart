abstract class QueryBuilder {
  String build();

  QueryBuilder select(String table, List<String> columns);

  QueryBuilder insert(String table, Map<String, dynamic> values);

  QueryBuilder update(String table, Map<String, dynamic> values);

  QueryBuilder delete(String table);
}

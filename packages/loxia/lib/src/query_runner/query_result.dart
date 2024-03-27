class QueryResult {
  final dynamic raw;

  final List<Map<String, dynamic>> data;

  final int affectedRows;

  QueryResult({
    required this.raw,
    required this.data,
    required this.affectedRows,
  });
}

import 'package:loxia/src/enums/order_by_enum.dart';
import 'package:loxia/src/queries/where_clause.dart';

class FindOptions {
  FindOptions({
    this.where,
    this.select = const [],
    this.orderBy = const {},
    this.limit = 100,
    this.skip = 0,
    this.relations = const {},
  });

  final List<String> select;

  final WhereClause? where;

  final Map<String, OrderBy> orderBy;

  final int? limit;

  final int? skip;

  final Map<String, bool> relations;
}

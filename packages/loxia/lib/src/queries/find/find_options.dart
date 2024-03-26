import 'package:loxia/src/enums/order_by_enum.dart';

class FindOptions {

  FindOptions({
    this.where = const [],
    this.select = const [],
    this.orderBy = const {},
    this.limit,
    this.skip,
    this.relations = const {},
  });

  final List<String> select;

  final List<Map<String, dynamic>> where;

  final Map<String, OrderBy> orderBy;

  final int? limit;

  final int? skip;

  final Map<String, bool> relations;

}
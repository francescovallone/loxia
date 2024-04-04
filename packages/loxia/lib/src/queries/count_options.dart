import 'package:loxia/src/queries/find_options.dart';
import 'package:loxia/src/queries/where_clause.dart';

class CountOptions {

  final WhereClause? where;
  
  final String select;

  final bool distinct;

  CountOptions({
    this.where,
    this.select = '*',
    this.distinct = false
  });

  factory CountOptions.fromFindOptions(FindOptions options, bool distinct) => CountOptions(
    where: options.where,
    select: options.select.isEmpty ? '*' : options.select.first,
    distinct: distinct
  );

}
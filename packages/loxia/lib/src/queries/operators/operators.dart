import 'package:loxia/src/queries/where_clause.dart';

abstract class Operator {

  final dynamic value;

  const Operator(this.value);

}

class Equal extends Operator {
  const Equal(super.value);
}

class NotEqual extends Operator {
  const NotEqual(super.value);
}

class In extends Operator {

  final List<dynamic> values;
  
  const In(this.values): super(values);
}

class NotIn extends Operator {
  final List<dynamic> values;
  
  const NotIn(this.values): super(values);
}

class And extends Operator {
  final List<WhereClause> clauses;
  
  const And(this.clauses): super(clauses);
}

class Or extends Operator {
  final List<WhereClause> clauses;
  
  const Or(this.clauses): super(clauses);
}


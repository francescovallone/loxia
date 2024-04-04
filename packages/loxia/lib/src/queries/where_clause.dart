import 'package:loxia/src/queries/operators/operators.dart';
import 'package:loxia/src/transformers/transformer.dart';

class WhereClause {
  final String? _field;
  final Operator _operator;

  WhereClause({String? field, required Operator operator})
      : _field = field,
        _operator = operator;

  String? get field => _field;
  Operator get operator => _operator;

  @override
  String toString() {
    return 'WhereClause{_field: $_field, _operator: $_operator}';
  }

  static String build(
      WhereClause whereClause, Transformer transformer, String tableName,
      [String query = '']) {
    if (whereClause.operator is And || whereClause.operator is Or) {
      List<String> operators = [];
      for (var i = 0; i < whereClause.operator.value.length; i++) {
        final clause = whereClause.operator.value[i] as WhereClause;
        operators.add(WhereClause.build(
            WhereClause(
                field: clause.field ?? whereClause.field,
                operator: clause.operator),
            transformer,
            tableName,
            query));
      }
      return '(${operators.join('${transformer.transform(whereClause.operator)} ')})';
    } else {
      if (whereClause.field == null) {
        throw Exception('Field is required when operator is not And or Or');
      }
      return '${!whereClause.field!.contains('.') ? '$tableName.${whereClause.field}' : '${whereClause.field}'}${transformer.transform(whereClause.operator)}';
    }
  }
}

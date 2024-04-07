import 'package:loxia/src/queries/operators/operators.dart';

import 'transformer.dart';

class SqlOperatorTransformer extends Transformer {
  @override
  String transform(covariant Operator element) {
    return switch (element.runtimeType.toString()) {
      "In" =>
        ' IN (${element.value.map((e) => e is String ? '"$e"' : e).join(', ')})',
      "NotIn" =>
        ' NOT IN (${element.value.map((e) => e is String ? '"$e"' : e).join(', ')})',
      "Equal" =>
        ' = ${element.value is String ? '"${element.value}"' : element.value}',
      "NotEqual" =>
        ' != ${element.value is String ? '"${element.value}"' : element.value}',
      "GreaterThan" =>
        ' > ${element.value is String ? '"${element.value}"' : element.value}',
      "GreaterThanOrEqual" =>
        ' >= ${element.value is String ? '"${element.value}"' : element.value}',
      "LessThan" =>
        ' < ${element.value is String ? '"${element.value}"' : element.value}',
      "LessThanOrEqual" =>
        ' <= ${element.value is String ? '"${element.value}"' : element.value}',
      "And" => ' AND',
      "Or" => ' OR',
      _ => throw Exception('Invalid operator')
    };
  }
}

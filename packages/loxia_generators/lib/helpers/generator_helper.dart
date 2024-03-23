import 'package:analyzer/dart/element/element.dart';
import 'package:loxia_generators/helpers/column_utils.dart';
import 'package:loxia_generators/helpers/types/column_config.dart';

import 'types/class_config.dart';

class GeneratorHelper {
  final _addedMembers = <String>{};
  ClassElement element;
  ClassConfig annotation = ClassConfig();

  GeneratorHelper(this.element);

  ColumnConfig columnFor(FieldElement field) {
    return columnForField(field, annotation);
  }

  Iterable<String> generate() sync* {
    final sortedFields = createSortedFieldSet(element);

    // Used to keep track of why a field is ignored. Useful for providing
    // helpful errors when generating constructor calls that try to use one of
    // these fields.
    final unavailableReasons = <String, String>{};

    final accessibleFields = sortedFields.fold<Map<String, FieldElement>>(
      <String, FieldElement>{},
      (map, field) {
        final column = columnFor(field);
        print('Column: $column, ${field.computeConstantValue()}');
        if (!field.isPublic) {
          unavailableReasons[field.name] = 'It is assigned to a private field.';
        } else if (field.getter == null) {
          assert(field.setter != null);
          unavailableReasons[field.name] =
              'Setter-only properties are not supported.';
        }  else {
          assert(!map.containsKey(field.name));
          map[field.name] = field;
        }

        return map;
      },
    );

    var accessibleFieldSet = accessibleFields.values.toSet();

    accessibleFieldSet
      .fold(
        <String>{},
        (Set<String> set, fe) {
          final column = columnFor(fe);
          final name = column.name ?? fe.name;
          if (!set.add(name)) {
            throw Exception(
              'More than one field has the name "$name". '
            );
          }
          return set;
        },
      );

    yield* _addedMembers;
  }
}
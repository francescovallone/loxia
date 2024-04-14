import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:loxia_generators/src/entity/information.dart';

class ColumnHelper {
  dynamic getDefaultValue(DartObject? defaultValue) {
    if (defaultValue == null || defaultValue.isNull) return null;
    if (defaultValue.type?.isDartCoreBool == true) {
      return defaultValue.toBoolValue();
    }
    if (defaultValue.type?.isDartCoreDouble == true) {
      return defaultValue.toDoubleValue();
    }
    if (defaultValue.type?.isDartCoreInt == true) {
      return defaultValue.toIntValue();
    }
    if (defaultValue.type?.isDartCoreString == true) {
      return "'${defaultValue.toStringValue()}'";
    }
    if (defaultValue.type?.isDartCoreList == true) {
      return defaultValue.toListValue();
    }
    if (defaultValue.type?.isDartCoreMap == true) {
      return defaultValue.toMapValue();
    }
    if (defaultValue.type?.isDartCoreSet == true) {
      return defaultValue.toSetValue();
    }
    return defaultValue;
  }

  dynamic getValueOrDefault(ColumnInformation column) {
    if(column.defaultValue != null){
      print(column.defaultValue is String && column.defaultValue == "'CURRENT_TIMESTAMP'");
      print(column.name);
      print(column.defaultValue);
      print(column.defaultValue is String);
      if(column.defaultValue is String && column.defaultValue == "'CURRENT_TIMESTAMP'"){
        return 'DateTime.now()';
      }
    }
    return column.defaultValue;
  }

  dynamic getFallbackValue(String type) => switch(type) {
    'bool' => 'false',
    'double' => 'double.nan',
    'int' => '-1',
    'String' => "''",
    'List' => '[]',
    'Map' => '{}',
    'Set' => '{}',
    _ => 'null'
  };

  String getRelationType(DartObject relation) => switch(relation.type?.getDisplayString(withNullability: false)){
    'ManyToOne' => 'RelationType.manyToOne',
    'OneToMany' => 'RelationType.oneToMany',
    'OneToOne' => 'RelationType.oneToOne',
    'ManyToMany' => 'RelationType.manyToMany',
    _ => 'RelationType.none'
  };

  String getRelationEntity(DartType type) {
    return (type is ParameterizedType
            ? type.typeArguments.firstOrNull ?? type
            : type)
        .getDisplayString(withNullability: false);
  }
}

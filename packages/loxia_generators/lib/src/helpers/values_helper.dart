import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/type.dart';

class ColumnHelper {

  dynamic getDefaultValue(DartObject? defaultValue) {
    if(defaultValue == null || defaultValue.isNull) return null;
    if(defaultValue.type?.isDartCoreBool == true) return defaultValue.toBoolValue();
    if(defaultValue.type?.isDartCoreDouble == true) return defaultValue.toDoubleValue();
    if(defaultValue.type?.isDartCoreInt == true) return defaultValue.toIntValue();
    if(defaultValue.type?.isDartCoreString == true) return "'${defaultValue.toStringValue()}'";
    if(defaultValue.type?.isDartCoreList == true) return defaultValue.toListValue();
    if(defaultValue.type?.isDartCoreMap == true) return defaultValue.toMapValue();
    if(defaultValue.type?.isDartCoreSet == true) return defaultValue.toSetValue();
    return defaultValue;
  }

  String getRelationType(DartObject relation) {
    if(relation.type?.getDisplayString(withNullability: false) == 'ManyToOne') return 'RelationType.manyToOne';
    if(relation.type?.getDisplayString(withNullability: false) == 'OneToMany') return 'RelationType.oneToMany';
    if(relation.type?.getDisplayString(withNullability: false) == 'OneToOne') return 'RelationType.oneToOne';
    if(relation.type?.getDisplayString(withNullability: false) == 'ManyToMany') return 'RelationType.manyToMany';
    return 'RelationType.none';
  }

  DartType getRelationEntity(DartType type) {
    return (type is ParameterizedType ? type.typeArguments.firstOrNull ?? type : type);
  }
  

}
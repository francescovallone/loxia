import 'package:analyzer/dart/constant/value.dart';

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
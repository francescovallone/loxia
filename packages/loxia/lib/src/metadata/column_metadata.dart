
import 'package:loxia/src/entity/entity.dart';

import 'relation_metadata.dart';

class ColumnMetadata {

  final GeneratedEntity entity;

  final String target;

  final RelationMetadata? relation;

  final String name;

  final String type;

  final String length;

  final int? width;

  final String? charset;

  final bool primary;

  final bool generated;

  final bool nullable;

  final bool unique;

  final dynamic defaultValue;

  final ColumnMetadata? referenceColumn;

  String get propertyPath {
    final path = StringBuffer();
    path.write(name);
    if(referenceColumn?.name != name){
      path.write('.${referenceColumn?.name}');
    }
    return path.toString();    
  }

  String get databasePath {
    final path = StringBuffer();
    path.write(databaseName);
    if(referenceColumn?.databaseName != databaseName){
      path.write('.${referenceColumn?.databaseName}');
    }
    return path.toString();
  }

  final String databaseName;

  String get aliasName {
    return propertyPath.replaceAll('.', '_');
  }

  const ColumnMetadata({
    required this.name,
    required this.type,
    this.nullable = false,
    this.unique = false,
    this.defaultValue,
  });

}
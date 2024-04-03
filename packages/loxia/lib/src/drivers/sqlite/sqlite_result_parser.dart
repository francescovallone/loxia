import 'package:loxia/src/entity/entity.dart';
import 'package:loxia/src/entity/table.dart';
import 'package:loxia/src/metadata/column_metadata.dart';
import 'package:loxia/src/metadata/relation_metadata.dart';
import 'package:loxia/src/queries/result_parser.dart';

class SqliteResultParser extends ResultParser{

  final GeneratedEntity entity;
  final List<GeneratedEntity> relations;

  Table get table => entity.schema.table;

  SqliteResultParser(this.entity, this.relations);

  @override
  List<Map<String, dynamic>> parse(List<Map<String, dynamic>> result) {
    final relationsToParse = [];
    final parsed = List<Map<String, dynamic>>.empty(growable: true);
    for(var r in result){
      Map<String, dynamic> parsedResult = {};
      for(var entry in r.entries){
        var column = table.columns.where((element) => element.name == entry.key).firstOrNull;
        if(column == null) continue;
        final possibleRelation = table.relations.where((element) => element.column == entry.key);
        print(possibleRelation);
        if(possibleRelation.isNotEmpty){
          relationsToParse.add(entry);
        }else{
          parsedResult[entry.key] = _parseColumn(column, entry);
        }
      }
      print(parsedResult);
      parsed.add(parsedResult);
    }
    return parsed;
  }

  MapEntry<String, dynamic> _parseRelation(RelationMetadata relation, MapEntry<String, dynamic> e, ){
      final relatedEntity = relations.where((element) => element.runtimeType == relation.entity).firstOrNull;
      if(relatedEntity == null) return e;
      ColumnMetadata? relatedColumn = relatedEntity.schema.table.columns.where((element) => element.name == relation.referenceColumn).firstOrNull;
      relatedColumn ??= relatedEntity.schema.table.columns.where((element) => element.primaryKey).firstOrNull;
      return MapEntry(e.key, {
        entity
      });
  }

  dynamic _parseColumn(ColumnMetadata column, MapEntry<String, dynamic> e){
    if(column.type == 'DateTime'){
      return DateTime.parse(e.value);
    }
    if(column.type == 'bool'){
      return e.value == 1;
    }
    return e.value;
  }
  
}
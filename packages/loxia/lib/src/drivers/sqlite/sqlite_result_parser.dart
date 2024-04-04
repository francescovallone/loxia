import 'package:loxia/src/entity/entity.dart';
import 'package:loxia/src/entity/table.dart';
import 'package:loxia/src/metadata/column_metadata.dart';
import 'package:loxia/src/queries/result_parser.dart';

class SqliteResultParser extends ResultParser{

  final GeneratedEntity entity;
  final List<GeneratedEntity> relations;

  Table get table => entity.schema.table;

  SqliteResultParser(this.entity, this.relations);

  @override
  List<Map<String, dynamic>> parse(List<Map<String, dynamic>> result) {
    final parsedRelations = {};
    final parsed = List<Map<String, dynamic>>.empty(growable: true);
    for(var r in result){
      final currentRow = Map<String, dynamic>.from(r);
      parsedRelations.clear();
      Map<String, dynamic> parsedResult = {};
      for(var entry in currentRow.entries){
        var column = table.columns.where((element) => element.name == entry.key).firstOrNull;
        if(column == null) continue;
        parsedResult[entry.key] = _parseColumn(column, entry);
      }
      currentRow.removeWhere((key, value) => parsedResult.containsKey(key));
      final relationsToParse = [
        for(var entry in currentRow.entries)
          table.relations.where((element) => element.column == entry.key).firstOrNull
      ].where((element) => element != null).toList();
      for(final relation in relationsToParse){
        final relationEntity = relations.where((element) => element.runtimeType == relation!.entity).firstOrNull;
        if(relationEntity == null) continue;
        final relationTable = relationEntity.schema.table;
        final entries = <MapEntry<String, dynamic>>[];
        for(var entry in currentRow.entries){
          if(relationTable.columns.where((element) => element.name == entry.key || entry.key.split('.').last == element.name).isNotEmpty){
            entries.add(entry);
          }
        }
        parsedResult[relation!.column] = _parseRelation(
          relationEntity, 
          entries,
        );
      }
      parsed.add(parsedResult);
    }
    return parsed;
  }

  dynamic _parseRelation(
    GeneratedEntity relationEntity, 
    List<MapEntry<String, dynamic>> relationColumns,
  ){
      final columns = Map<String, dynamic>.fromEntries(relationColumns.map((e) => MapEntry(e.key.split('.').last, e.value)));
      return columns;
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
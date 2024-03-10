import 'package:loxia/src/entity/primary_key.dart';

import 'options/driver_options.dart';

mixin DriverOperations {

  Future<List<Map<String, dynamic>>> find(FindQuery query);

  Future<Map<String, dynamic>> findById(dynamic id);

  Future<Map<String, dynamic>> findOne(FindOneQuery query);

}

abstract class Driver<T extends DriverOptions> {

  Future<void> init(T options);

  Future<void> dispose();

}
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/loxia_generator.dart';

/// Builds generators for `build_runner` to run
Builder loxiaBuilder(BuilderOptions options) {
  return SharedPartBuilder(
    [LoxiaGenerator(options.config)],
    'loxia',
  );
}
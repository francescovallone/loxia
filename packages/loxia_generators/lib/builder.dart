import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/loxia_generator.dart';

/// Builds generators for `build_runner` to run
Builder loxiaBuilder(BuilderOptions options) {
  return SharedPartBuilder(
    [
      _UnifiedGenerator(
        [
          LoxiaGenerator(options.config),
        ],
      ),
    ],
    'loxia',
  );
}

class _UnifiedGenerator extends Generator {
  final List<GeneratorForAnnotation> _generators;

  _UnifiedGenerator([
    this._generators = const [],
  ]);

  @override
  String generate(LibraryReader library, BuildStep buildStep) {
    final values = <String>{};

    for (var generator in _generators) {
      for (var annotatedElement
          in library.annotatedWith(generator.typeChecker)) {
        final generatedValue = generator.generateForAnnotatedElement(
            annotatedElement.element, annotatedElement.annotation, buildStep);
        for (var value in _normalizeGeneratorOutput(generatedValue)) {
          assert(value.length == value.trim().length);
          values.add(value);
        }
      }
    }

    return values.join('\n\n');
  }

  Iterable<String> _normalizeGeneratorOutput(Object? value) {
    if (value == null) {
      return const [];
    } else if (value is String) {
      value = [value];
    }

    if (value is Iterable) {
      return value.where((e) => e != null).map((e) {
        if (e is String) {
          return e.trim();
        }

        throw _argError(e as Object);
      }).where((e) => e.isNotEmpty);
    }
    throw _argError(value);
  }

  ArgumentError _argError(Object value) => ArgumentError(
      'Must be a String or be an Iterable containing String values. '
      'Found `${Error.safeToString(value)}` (${value.runtimeType}).');

  @override
  String toString() => 'LoxiaGenerator';
}

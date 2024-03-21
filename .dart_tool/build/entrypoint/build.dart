// ignore_for_file: directives_ordering
// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:build_runner_core/build_runner_core.dart' as _i1;
import 'package:reflectable/reflectable_builder.dart' as _i2;
import 'package:build_config/build_config.dart' as _i3;
import 'package:build_resolvers/builder.dart' as _i4;
import 'dart:isolate' as _i5;
import 'package:build_runner/build_runner.dart' as _i6;
import 'dart:io' as _i7;

final _builders = <_i1.BuilderApplication>[
  _i1.apply(
    r'reflectable:reflectable',
    [_i2.reflectableBuilder],
    _i1.toRoot(),
    hideOutput: false,
    defaultGenerateFor: const _i3.InputSet(include: [
      r'benchmark/**.dart',
      r'bin/**.dart',
      r'example/**.dart',
      r'lib/main.dart',
      r'test/**.dart',
      r'tool/**.dart',
      r'web/**.dart',
    ]),
  ),
  _i1.apply(
    r'build_resolvers:transitive_digests',
    [_i4.transitiveDigestsBuilder],
    _i1.toAllPackages(),
    isOptional: true,
    hideOutput: true,
    appliesBuilders: const [r'build_resolvers:transitive_digest_cleanup'],
  ),
  _i1.applyPostProcess(
    r'build_resolvers:transitive_digest_cleanup',
    _i4.transitiveDigestCleanup,
  ),
];
void main(
  List<String> args, [
  _i5.SendPort? sendPort,
]) async {
  var result = await _i6.run(
    args,
    _builders,
  );
  sendPort?.send(result);
  _i7.exitCode = result;
}

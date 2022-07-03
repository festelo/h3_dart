import 'dart:io';

import 'common/common.dart';

void main(List<String> args) {
  bool removeMode = (args.isNotEmpty && args[0] == 'remove') ||
      Platform.environment['remove'] == 'true';
  if (removeMode) {
    for (final package in Package.values) {
      var pubspec = pubspecFileFor(package).readAsStringSync();
      pubspec = removeDependencyOverrides(fileContent: pubspec);
      pubspecFileFor(package).writeAsStringSync(pubspec);

      final examples = getExamples(package);
      for (final example in examples) {
        var examplePubspec = example.pubspecFile.readAsStringSync();
        examplePubspec = removeDependencyOverrides(fileContent: examplePubspec);
        example.pubspecFile.writeAsStringSync(examplePubspec);
      }
    }
  } else {
    for (final package in Package.values) {
      var pubspec = pubspecFileFor(package).readAsStringSync();
      List<Package> packagesToOverride = [];
      for (final packageDependency in Package.values) {
        if (package == packageDependency) continue;
        final dependencyVersion =
            getDependencyVersionFor(packageDependency, fileContent: pubspec);
        if (dependencyVersion == null) continue;
        packagesToOverride.add(packageDependency);
      }
      if (packagesToOverride.isNotEmpty) {
        final dependencyOverridesString = 'dependency_overrides:\n' +
            packagesToOverride
                .map((e) => '  ${e.name}:\n    path: ../${e.name}')
                .join('\n');
        pubspec = appendOrReplaceDependencyOverrides(
          fileContent: pubspec,
          newDependencyOverrides: dependencyOverridesString,
        );
        pubspecFileFor(package).writeAsStringSync(pubspec);

        final examples = getExamples(package);
        for (final example in examples) {
          final exampleDependencyOverridesString = 'dependency_overrides:\n' +
              packagesToOverride
                  .map((e) =>
                      '  ${e.name}:\n    path: ${pathOffsetForLevel(example.level)}${e.name}')
                  .join('\n');

          var examplePubspec = example.pubspecFile.readAsStringSync();
          examplePubspec = appendOrReplaceDependencyOverrides(
            fileContent: examplePubspec,
            newDependencyOverrides: exampleDependencyOverridesString,
          );
          example.pubspecFile.writeAsStringSync(examplePubspec);
        }
      }
    }
  }
}

String pathOffsetForLevel(int level) =>
    [for (var i = 0; i < level + 1; i++) '..'].join('/') + '/';

class Example {
  final File pubspecFile;
  final int level;

  const Example(this.pubspecFile, this.level);
}

List<Example> getExamples(Package package) {
  final exampleDir =
      Directory(pubspecFileFor(package).parent.path + '/example');
  if (!exampleDir.existsSync()) return [];
  final examplePubspecFile = File(exampleDir.path + '/pubspec.yaml');
  if (examplePubspecFile.existsSync()) {
    return [Example(examplePubspecFile, 1)];
  }

  final resList = <Example>[];
  for (final d in exampleDir.listSync()) {
    final examplePubspecFile = File(d.path + '/pubspec.yaml');
    if (examplePubspecFile.existsSync()) {
      resList.add(Example(examplePubspecFile, 2));
    }
  }
  return resList;
}

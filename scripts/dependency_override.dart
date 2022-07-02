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
      }
    }
  }
}

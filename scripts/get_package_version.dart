import 'dart:io';

import 'common.dart';

final target = Platform.environment['target'];

void main() async {
  final package = Package.tryParse(target ?? '');
  if (package != null) {
    resolveVersionFor(package);
  } else {
    exitCode = 1;
    print(
        'unknown target $target, it must be one of equal to one of following items: ${Package.values.join(', ')}');
  }
}

Future<void> resolveVersionFor(Package package) async {
  final pubspec = await pubspecFileFor(package).readAsString();
  final version = libraryVersionRegex.firstMatch(pubspec)?.group(1);
  if (version == null) {
    exitCode = 1;
    print('h3_dart: version unknown');
    return;
  }
  print(version.trim());
  return;
}

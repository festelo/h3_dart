import 'dart:io';

import 'common/common.dart';

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
  final version = getLibraryVersion(fileContent: pubspec);
  if (version == null) {
    exitCode = 1;
    print('h3_dart: version unknown');
    return;
  }
  print(version.trim());
  return;
}

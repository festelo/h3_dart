import 'dart:io';

import 'common.dart';

final target = Platform.environment['target'];

void main() async {
  if (target == 'h3_dart') {
    resolveVersionFor(h3dartPubspecFile);
  } else if (target == 'h3_flutter') {
    resolveVersionFor(h3flutterPubspecFile);
  } else {
    exitCode = 1;
    print('unknown target $target, it must be h3_dart or h3_flutter');
  }
}

Future<void> resolveVersionFor(File file) async {
  final pubspec = await file.readAsString();
  final version = libraryVersionRegex.firstMatch(pubspec)?.group(1);
  if (version == null) {
    exitCode = 1;
    print('h3_dart: version unknown');
    return;
  }
  print(version.trim());
  return;
}

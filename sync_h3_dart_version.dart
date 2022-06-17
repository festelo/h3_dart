import 'dart:io';

final h3DartLibraryVersionRegex = RegExp(r'version: (.+)$', multiLine: true);
final h3DartDependencyVersionRegex = RegExp(r'h3_dart: (.+)$', multiLine: true);
final versionMatchRegex = RegExp(r'\^?{VERSION}\s*$', multiLine: true);

final testMode = Platform.environment['test'] == 'true';

void main() async {
  final h3dartPubspecFile = File('h3_dart/pubspec.yaml');
  final h3flutterPubspecFile = File('h3_flutter/pubspec.yaml');

  final h3dartPubspec = await h3dartPubspecFile.readAsString();
  var h3flutterPubspec = await h3flutterPubspecFile.readAsString();

  final h3dartVersion =
      h3DartLibraryVersionRegex.firstMatch(h3dartPubspec)?.group(1);
  if (h3dartVersion == null) {
    exitCode = 1;
    print('h3_dart version not found');
    return;
  }
  print('h3_dart version: $h3dartVersion');

  final h3dartVersionInH3Flutter =
      h3DartDependencyVersionRegex.firstMatch(h3flutterPubspec)?.group(1);
  if (h3dartVersionInH3Flutter == null) {
    exitCode = 1;
    print('h3_dart dependency not found for h3_flutter');
    return;
  }
  print('h3_dart version used for h3_flutter: $h3dartVersionInH3Flutter');

  if (testMode) {
    if (!versionMatch(h3dartVersion, h3dartVersionInH3Flutter)) {
      exitCode = 1;
      print(
        'h3_dart version used for h3_flutter does not match current h3_dart version',
      );
      return;
    }

    print(
      'h3_dart version used for h3_flutter does match current h3_dart version',
    );
    return;
  }

  if (!versionMatch(h3dartVersion, h3dartVersionInH3Flutter)) {
    h3flutterPubspec = h3flutterPubspec.replaceFirst(
      h3DartDependencyVersionRegex,
      'h3_dart: ^$h3dartVersion',
    );
    await h3flutterPubspecFile.writeAsString(h3flutterPubspec);
    print('version updated in h3_flutter');
    return;
  }

  print('no changes needed');
  return;
}

bool versionMatch(String original, String dependency) {
  final escapedOriginal = RegExp.escape(original);
  final regex = RegExp(
    versionMatchRegex.pattern.replaceAll('{VERSION}', escapedOriginal),
  );
  return regex.hasMatch(dependency);
}

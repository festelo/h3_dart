import 'dart:io';

import 'common.dart';

File pubspecFileFor(Package package) => File('${package.name}/pubspec.yaml');

String? getLibraryVersion({required String fileContent}) {
  return libraryVersionRegex.firstMatch(fileContent)?.group(1);
}

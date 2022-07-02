import 'dart:io';

import 'common/common.dart';

final testMode = Platform.environment['test'] == 'true';

void main() {
  final versions = getPackageVersions();
  final notUpToDateMessages = <String>[];
  bool anyVersionUpdated = false;
  for (final package in Package.values) {
    var fileContent = pubspecFileFor(package).readAsStringSync();
    for (final versionEntry in versions.entries) {
      if (versionEntry.key == package) continue;

      final usedVersion =
          getDependencyVersionFor(versionEntry.key, fileContent: fileContent);
      if (usedVersion == null) continue;

      if (versionMatch(versionEntry.value, usedVersion)) {
        continue;
      }

      if (testMode) {
        notUpToDateMessages.add(
          'package:${package.name}: version for ${versionEntry.key.name} is not up-to-date. Current: $usedVersion, latest: ${versionEntry.value}',
        );
        continue;
      }

      fileContent = replaceVersionFor(
        versionEntry.key,
        newVersion: versionEntry.value,
        fileContent: fileContent,
      );

      anyVersionUpdated = true;
      print(
        'package:${package.name}: version for ${versionEntry.key.name} has been updated from $usedVersion to ${versionEntry.value}',
      );
      pubspecFileFor(package).writeAsStringSync(fileContent);
    }
  }

  if (notUpToDateMessages.isNotEmpty) {
    throw Exception(notUpToDateMessages.join('\n'));
  }
  if (!anyVersionUpdated) {
    print('no changes needed');
  }
}

Map<Package, String> getPackageVersions() {
  Map<Package, String> res = {};
  final exceptionMessages = <String>[];
  for (final package in Package.values) {
    final fileContent = pubspecFileFor(package).readAsStringSync();
    final version = getLibraryVersion(fileContent: fileContent);
    if (version == null) {
      exceptionMessages.add('${package.name} library version not found');
      continue;
    }
    res[package] = version;
  }
  if (exceptionMessages.isNotEmpty) {
    throw Exception(exceptionMessages.join('\n'));
  }
  return res;
}

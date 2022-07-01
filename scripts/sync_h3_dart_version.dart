import 'dart:io';

import 'common.dart';

final packageDependencyVersionRegex =
    RegExp(r'{PACKAGE}: (.+)', multiLine: true);
final versionMatchRegex = RegExp(r'\^?{VERSION}\s*$', multiLine: true);

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

String? getLibraryVersion({required String fileContent}) {
  return libraryVersionRegex.firstMatch(fileContent)?.group(1);
}

String? getDependencyVersionFor(Package package,
    {required String fileContent}) {
  final escapedName = RegExp.escape(package.name);
  final regex = RegExp(
    packageDependencyVersionRegex.pattern.replaceAll('{PACKAGE}', escapedName),
  );

  return regex.firstMatch(fileContent)?.group(1);
}

String replaceVersionFor(
  Package package, {
  required String newVersion,
  required String fileContent,
}) {
  final escapedName = RegExp.escape(package.name);
  final regex = RegExp(
    packageDependencyVersionRegex.pattern.replaceAll('{PACKAGE}', escapedName),
  );

  fileContent = fileContent.replaceFirst(
    regex,
    '${package.name}: ^$newVersion',
  );

  return fileContent;
}

bool versionMatch(String original, String dependency) {
  final escapedOriginal = RegExp.escape(original);
  final regex = RegExp(
    versionMatchRegex.pattern.replaceAll('{VERSION}', escapedOriginal),
  );
  return regex.hasMatch(dependency);
}

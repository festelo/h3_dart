import 'dart:io';

import 'common.dart';

File pubspecFileFor(Package package) => File('${package.name}/pubspec.yaml');

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

String removeDependencyOverrides({required String fileContent}) {
  String replace(Match match) {
    final wholeMatch = match.group(0)!;
    final groupToDelete = match.group(1)!;
    final resStart = wholeMatch.substring(0, wholeMatch.indexOf(groupToDelete));
    var resEnd = wholeMatch.substring(resStart.length + groupToDelete.length);
    if (resEnd.isNotEmpty) {
      resEnd = '\n' + resEnd.trimLeft();
    }
    return resStart + resEnd;
  }

  if (dependencyOverridesRegex.hasMatch(fileContent)) {
    return fileContent.replaceFirstMapped(
      dependencyOverridesRegex,
      replace,
    );
  }
  return fileContent.replaceFirstMapped(
    dependencyOverridesRegexEOF,
    replace,
  );
}

String appendOrReplaceDependencyOverrides({
  required String fileContent,
  required String newDependencyOverrides,
}) {
  newDependencyOverrides = newDependencyOverrides.trim();
  String replace(Match match) {
    final wholeMatch = match.group(0)!;
    final groupToDelete = match.group(1)!;
    final resStart = wholeMatch.substring(0, wholeMatch.indexOf(groupToDelete));
    var resEnd = wholeMatch.substring(resStart.length + groupToDelete.length);
    if (resEnd.isNotEmpty) {
      resEnd = '\n' + resEnd.trimLeft();
    }
    return resStart + '\n' + newDependencyOverrides + '\n' + resEnd;
  }

  if (dependencyOverridesRegex.hasMatch(fileContent)) {
    return fileContent.replaceFirstMapped(
      dependencyOverridesRegex,
      replace,
    );
  }
  if (dependencyOverridesRegexEOF.hasMatch(fileContent)) {
    return fileContent.replaceFirstMapped(
      dependencyOverridesRegexEOF,
      replace,
    );
  }
  return fileContent.trim() + '\n\n' + newDependencyOverrides + '\n';
}

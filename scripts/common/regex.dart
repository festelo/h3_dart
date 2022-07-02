final packageDependencyVersionRegex =
    RegExp(r'{PACKAGE}: (.+)', multiLine: true);

final versionMatchRegex = RegExp(r'\^?{VERSION}\s*$', multiLine: true);

final libraryVersionRegex = RegExp(r'version: (.+)$', multiLine: true);

final dependencyOverridesRegex = RegExp(
    r'\n(\s*dependency_overrides:(?:[\S\s]*?))(?:^[\S])',
    multiLine: true);

final dependencyOverridesRegexEOF =
    RegExp(r'\n(\s*dependency_overrides:(?:[\S\s]*))', multiLine: true);

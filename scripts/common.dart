import 'dart:io';

final libraryVersionRegex = RegExp(r'version: (.+)$', multiLine: true);

File pubspecFileFor(Package package) => File('${package.name}/pubspec.yaml');

enum Package {
  h3Common(name: 'h3_common'),
  h3Ffi(name: 'h3_ffi'),
  h3Web(name: 'h3_web'),
  geojson2h3(name: 'geojson2h3'),
  h3Dart(name: 'h3_dart'),
  h3Flutter(name: 'h3_flutter');

  const Package({
    required this.name,
  });

  final String name;

  static Package? tryParse(String string) {
    for (final p in Package.values) {
      if (p.name == string) {
        return p;
      }
    }
    return null;
  }
}

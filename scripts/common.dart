import 'dart:io';

final libraryVersionRegex = RegExp(r'version: (.+)$', multiLine: true);

final h3dartPubspecFile = File('h3_dart/pubspec.yaml');
final h3flutterPubspecFile = File('h3_flutter/pubspec.yaml');

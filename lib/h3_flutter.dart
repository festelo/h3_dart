export 'src/h3.dart';
export 'src/geo_coord.dart';

import 'dart:ffi';
import 'dart:io';

import 'package:h3_flutter/src/geojson2h3.dart';
import 'package:h3_flutter/src/h3.dart';

import 'src/generated/generated_bindings.dart';

final DynamicLibrary _h3cLib = Platform.isAndroid
    ? DynamicLibrary.open('libh3lib.so')
    : DynamicLibrary.process();

final h3c = H3C(_h3cLib);
final h3 = H3(h3c);
final geojson2H3 = Geojson2H3(h3);

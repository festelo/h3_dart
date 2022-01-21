
import 'dart:async';

import 'package:flutter/services.dart';

class H3Flutter {
  static const MethodChannel _channel = MethodChannel('h3_flutter');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}

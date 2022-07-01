import 'package:js/js_util.dart';

String? getJsErrorMessage(Object o) {
  final message = getProperty(o, 'message');
  if (message is String) return message;
  return null;
}

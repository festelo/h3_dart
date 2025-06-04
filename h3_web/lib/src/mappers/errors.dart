import 'dart:js_interop';

import 'package:h3_common/h3_common.dart';

@JS('Error')
extension type _H3JSError._(JSObject _) implements JSObject {
  external JSAny? get message;
  external JSAny? get code;
}

void wrapAndThrowJsException(Object o) {
  if (!(o as JSObject).isA<_H3JSError>()) {
    return;
  }

  final error = o as _H3JSError;
  final isCodeNumeric = error.code?.isA<JSNumber>() ?? false;
  if (!isCodeNumeric) {
    return;
  }

  final numericCode = (error.code as JSNumber).toDartInt;

  final code = numericCode >= 1000
      ? H3ExceptionCode.internal
      : H3ExceptionCode.values[numericCode];
  final message = error.message?.toString();
  final exception =
      message == null ? H3Exception.fromCode(code) : H3Exception(code, message);
  throw exception;
}

import 'dart:js_interop';

import 'package:h3_common/h3_common.dart';

/// An h3-js error: a JS `Error` with the H3 error code in `code`.
@JS('Error')
extension type _H3JSError._(JSObject _) implements JSObject {
  external JSAny? get message;
  external JSAny? get code;
}

/// Throws an [H3Exception] when [o] is an error thrown by h3-js.
///
/// Returns normally for anything else, so the caller can `rethrow` it.
void wrapAndThrowJsException(Object o) {
  // A Dart exception (an AssertionError, an H3Exception) is not a JS value.
  // Casting it to JSObject throws a TypeError under dart2wasm, so check first.
  // ignore: invalid_runtime_check_with_js_interop_types
  if (o is! JSObject || !o.isA<_H3JSError>()) {
    return;
  }

  final error = o as _H3JSError;
  final code = error.code;
  if (code == null || !code.isA<JSNumber>()) {
    return;
  }

  final numericCode = (code as JSNumber).toDartInt;
  final exceptionCode =
      numericCode >= 0 && numericCode < H3ExceptionCode.values.length
          ? H3ExceptionCode.values[numericCode]
          : H3ExceptionCode.internal;
  final message = error.message;
  throw message != null && message.isA<JSString>()
      ? H3Exception(exceptionCode, (message as JSString).toDart)
      : H3Exception.fromCode(exceptionCode);
}

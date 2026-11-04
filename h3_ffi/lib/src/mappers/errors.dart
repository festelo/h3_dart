import 'package:h3_common/h3_common.dart';

void throwIfError(int numericCode) {
  if (numericCode == 0) {
    return;
  }
  if (numericCode < 0 || numericCode >= H3ExceptionCode.internal.index) {
    throw H3Exception(
      H3ExceptionCode.internal,
      'Unknown H3 error code $numericCode',
    );
  }
  throw H3Exception.fromCode(H3ExceptionCode.values[numericCode]);
}

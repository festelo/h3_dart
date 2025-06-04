import 'package:h3_common/h3_common.dart';

void throwIfError(int numericCode) {
  if (numericCode == 0) {
    return;
  }
  final code = H3ExceptionCode.values[numericCode];
  throw H3Exception.fromCode(code);
}

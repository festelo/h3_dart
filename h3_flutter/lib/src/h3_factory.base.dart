import 'package:h3_common/h3_common.dart';

/// H3Factory is used to build H3 instance
abstract class BaseH3Factory {
  /// Resolves H3 for current platform
  H3 load();
}

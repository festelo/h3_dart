import 'package:h3_common/h3_common.dart';

/// H3Factory is used to build H3 instance
abstract class BaseH3Factory {
  /// Resolves H3 for current platform
  H3 load();

  /// Resolves H3 for current platform. On Web, loads h3-js first if it is
  /// not on the page yet.
  ///
  /// [h3JsUrl] overrides the default location of h3-js on Web.
  Future<H3> loadAsync({String? h3JsUrl});
}

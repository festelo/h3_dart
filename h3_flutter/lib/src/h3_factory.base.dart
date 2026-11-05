import 'dart:async';

import 'package:h3_common/h3_common.dart';
import 'package:h3_web/constants.dart';

/// H3Factory is used to build H3 instance
abstract class BaseH3Factory {
  /// Resolves H3 for current platform
  /// ```dart
  /// final h3 = await h3Factory.load();
  /// ```
  ///
  /// On Web, loads h3-js from [libraryUrl] first if it is not on the page yet,
  /// and returns a [Future] only in that case. On other platforms [libraryUrl]
  /// is ignored and H3 is returned immediately.
  FutureOr<H3> load({String libraryUrl = defaultH3JsUrl});
}

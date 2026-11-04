import 'package:h3_common/h3_common.dart';

/// H3Factory is used to build H3 instance
abstract class BaseH3Factory {
  /// Loads H3 from process, H3 C library must be loaded into this process first.
  /// ```dart
  /// DynamicLibrary.open('../h3_ffi/c/h3lib/build/h3.so');
  /// final h3 = h3Factory.process();
  /// h3.degsToRads(123);
  /// ```
  ///
  /// This feature is not available on Windows.
  H3 process();

  /// Loads H3 using specified [libraryPath]
  /// ```dart
  /// final h3 = h3Factory.byPath('../h3_ffi/c/h3lib/build/h3.so');
  /// h3.degsToRads(123);
  /// ```
  H3 byPath(String libraryPath);

  /// Loads H3 on Web
  H3 web();

  /// Loads h3-js if it is not on the page yet, then loads H3 on Web.
  ///
  /// [h3JsUrl] overrides the default location of h3-js.
  Future<H3> webAsync({String? h3JsUrl});
}

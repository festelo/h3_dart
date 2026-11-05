import 'package:h3_web/h3_web.dart';

import 'h3_factory.base.dart';

class H3Factory implements BaseH3Factory {
  const H3Factory();

  @override
  H3 process() => const H3Web();

  @override
  H3 byPath(String libraryPath) {
    throw UnsupportedError(
      'H3Factory.byPath(...) is not supported when compiled to Web',
    );
  }

  @override
  Future<H3> byUrl({String libraryUrl = defaultH3JsUrl}) async {
    await H3Web.ensureLoaded(url: libraryUrl);
    return const H3Web();
  }
}

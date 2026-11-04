import 'package:h3_web/h3_web.dart';

import 'h3_factory.base.dart';

class H3Factory implements BaseH3Factory {
  const H3Factory();

  @override
  H3 process() {
    throw UnsupportedError(
      'H3Factory.process() is not supported when compiled to Web',
    );
  }

  @override
  H3 byPath(String libraryPath) {
    throw UnsupportedError(
      'H3Factory.byPath(...) is not supported when compiled to Web',
    );
  }

  @override
  H3 web() {
    return H3Web();
  }

  @override
  Future<H3> webAsync({String? h3JsUrl}) async {
    await H3Web.ensureLoaded(url: h3JsUrl);
    return const H3Web();
  }
}

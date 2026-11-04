import 'package:h3_web/h3_web.dart';

import 'h3_factory.base.dart';

class H3Factory implements BaseH3Factory {
  const H3Factory();

  @override
  H3 load() {
    return const H3Web();
  }

  @override
  Future<H3> loadAsync({String? h3JsUrl}) async {
    await H3Web.ensureLoaded(url: h3JsUrl);
    return const H3Web();
  }
}

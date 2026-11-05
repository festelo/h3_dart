import 'dart:async';

import 'package:h3_web/h3_web.dart';

import 'h3_factory.base.dart';

class H3Factory implements BaseH3Factory {
  const H3Factory();

  @override
  FutureOr<H3> load({String libraryUrl = defaultH3JsUrl}) {
    if (H3Web.isH3JsLoaded) {
      return const H3Web();
    }
    return H3Web.ensureLoaded(url: libraryUrl).then((_) => const H3Web());
  }
}

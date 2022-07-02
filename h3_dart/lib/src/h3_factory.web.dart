import 'package:h3_web/h3_web.dart';

import 'h3_factory.base.dart';

class H3Factory implements BaseH3Factory {
  const H3Factory();

  @override
  H3 process() {
    throw UnimplementedError();
  }

  @override
  H3 byPath(String libraryPath) {
    throw UnimplementedError();
  }

  @override
  H3 web() {
    return H3Web();
  }
}

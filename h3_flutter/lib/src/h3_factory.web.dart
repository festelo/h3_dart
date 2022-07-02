import 'package:h3_web/h3_web.dart';

import 'h3_factory.base.dart';

class H3Factory implements BaseH3Factory {
  const H3Factory();

  @override
  H3 load() {
    return const H3Web();
  }
}

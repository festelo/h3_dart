import 'package:h3_common/h3_common.dart';

import 'h3_factory.base.dart';

class H3Factory implements BaseH3Factory {
  const H3Factory();

  @override
  H3 load() {
    throw UnimplementedError();
  }

  @override
  Future<H3> loadAsync({String? h3JsUrl}) {
    throw UnimplementedError();
  }
}

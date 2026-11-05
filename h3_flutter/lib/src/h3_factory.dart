import 'dart:async';

import 'package:h3_common/h3_common.dart';
import 'package:h3_web/constants.dart';

import 'h3_factory.base.dart';

class H3Factory implements BaseH3Factory {
  const H3Factory();

  @override
  FutureOr<H3> load({String libraryUrl = defaultH3JsUrl}) {
    throw UnimplementedError();
  }
}

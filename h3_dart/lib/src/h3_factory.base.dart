import 'package:h3_common/h3_common.dart';

abstract class BaseH3Factory {
  H3 process();

  H3 byPath(String libraryPath);

  H3 web();
}

import 'package:geojson2h3/geojson2h3.dart';
import 'package:h3_ffi/h3_ffi.dart';

void main() {
  final h3 = H3FfiFactory().byPath('../h3_ffi/c/h3/build/test.common');
  final geojson2h3 = Geojson2H3(h3);

  final feature = geojson2h3.h3ToFeature(BigInt.parse('0x89283082837ffff'));
  print('GeoJSON feature for 0x89283082837ffff: $feature');
}

import 'package:h3_common/h3_common.dart';

/// Returns the [resolution] cell that contains [coord] and its direct
/// neighbors.
///
/// Code written against [H3] works with every implementation:
/// h3_ffi, h3_web, h3_dart and h3_flutter.
List<H3Index> cellWithNeighbors(H3 h3, GeoCoord coord, int resolution) {
  final cell = h3.geoToCell(coord, resolution);
  return h3.gridDisk(cell, 1);
}

void main() {
  const converter = GeoCoordConverter(NativeAngleConverter());

  const coord = GeoCoord(lon: -122.4194, lat: 37.7749);
  final radians = converter.degreeToRadian(coord);
  print('$coord in radians: $radians');
  print('Back to degrees: ${converter.radianToDegree(radians)}');
}

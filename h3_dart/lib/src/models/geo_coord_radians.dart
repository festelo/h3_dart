import 'dart:math';

/// A pair of latitude and longitude coordinates in radians
///
/// World-wrapping supported - if you pass coordinates outside of the bounds
/// ([-pi, pi] for longitude and [-pi/2, pi/2] for latitude) they will be converted.
class GeoCoordRadians {
  const GeoCoordRadians({
    required double lon,
    required double lat,
  })  : lon = (lon + pi) % (pi * 2) - pi,
        lat = (lat + (pi / 2)) % pi - (pi / 2);

  final double lon;
  final double lat;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GeoCoordRadians && other.lat == lat && other.lon == lon;
  }

  @override
  int get hashCode => Object.hash(lat, lon);

  @override
  String toString() => 'GeoCoordRadians(lon: $lon, lat: $lat)';
}

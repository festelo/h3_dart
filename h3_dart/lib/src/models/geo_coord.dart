/// A pair of latitude and longitude coordinates
///
/// World-wrapping supported - if you pass coordinates outside of the bounds
/// ([-180, 180] for longitude and [-90, 190] for latitude) they will be converted.
class GeoCoord {
  const GeoCoord({
    required double lon,
    required double lat,
  })  : lon = (lon + 180) % 360 - 180,
        lat = (lat + 90) % 180 - 90;

  final double lon;
  final double lat;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GeoCoord && other.lat == lat && other.lon == lon;
  }

  @override
  int get hashCode => Object.hash(lat, lon);

  @override
  String toString() => 'GeoCoord(lon: $lon, lat: $lat)';
}

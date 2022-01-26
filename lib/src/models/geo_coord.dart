/// A pair of latitude and longitude coordinates
class GeoCoord {
  const GeoCoord({
    required this.lon,
    required this.lat,
  });

  final double lon;
  final double lat;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GeoCoord && other.lat == lat && other.lon == lon;
  }

  @override
  int get hashCode => lat.hashCode ^ lon.hashCode;

  @override
  String toString() => 'GeoCoord(lon: $lon, lon: $lat)';
}

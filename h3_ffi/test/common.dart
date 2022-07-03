import 'package:h3_ffi/h3_ffi.dart';

const geoPrecision = 12;

class ComparableGeoCoord {
  final String lat;
  final String lon;

  ComparableGeoCoord.fromLatLon({
    required double lat,
    required double lon,
  })  : lat = lat.toStringAsPrecision(geoPrecision),
        lon = lon.toStringAsPrecision(geoPrecision);

  ComparableGeoCoord.fromGeoCoord(GeoCoord geoCoord)
      : this.fromLatLon(lat: geoCoord.lat, lon: geoCoord.lon);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ComparableGeoCoord && other.lat == lat && other.lon == lon;
  }

  @override
  int get hashCode => lat.hashCode ^ lon.hashCode;

  @override
  String toString() => 'ComparableGeoCoord(lat: $lat, lon: $lon)';
}

bool almostEqual(num a, num b, [double factor = 1e-6]) =>
    (a - b).abs() < a * factor;

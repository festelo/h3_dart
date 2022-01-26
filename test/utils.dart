import 'package:h3_flutter/h3_flutter.dart';

const geoPrecision = 12;

class ComparableGeoCoord {
  final String lat;
  final String lon;

  ComparableGeoCoord({
    required this.lat,
    required this.lon,
  });
  ComparableGeoCoord.fromGeoCoord(GeoCoord geoCoord)
      : lat = geoCoord.lat.toStringAsPrecision(geoPrecision),
        lon = geoCoord.lon.toStringAsPrecision(geoPrecision);

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

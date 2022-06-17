import 'package:h3_dart/h3_dart.dart';

/// Converter between [GeoCoord] and [GeoCoordRadians]
class GeoCoordConverter {
  const GeoCoordConverter(AngleConverter angleConverter)
      : _angleConverter = angleConverter;

  final AngleConverter _angleConverter;

  GeoCoord radianToDegree(GeoCoordRadians radian) {
    return GeoCoord(
      lon: _angleConverter.radianToDegree(radian.lon),
      lat: _angleConverter.radianToDegree(radian.lat),
    );
  }

  GeoCoordRadians degreeToRadian(GeoCoord degree) {
    return GeoCoordRadians(
      lon: _angleConverter.degreeToRadian(degree.lon),
      lat: _angleConverter.degreeToRadian(degree.lat),
    );
  }
}

/// Extension to convert [GeoCoord] to [GeoCoordRadians]
extension GeoCoordConverterToRadianExtension on GeoCoord {
  GeoCoordRadians toRadians(GeoCoordConverter converter) {
    return converter.degreeToRadian(this);
  }
}

/// Extension to convert [GeoCoordRadians] to [GeoCoord]
extension GeoCoordConverterToDegreeExtension on GeoCoordRadians {
  GeoCoord toDegrees(GeoCoordConverter converter) {
    return converter.radianToDegree(this);
  }
}

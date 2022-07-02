import 'dart:math';

import 'package:h3_common/h3_common.dart';

/// Converter between radians and degrees
abstract class AngleConverter {
  double radianToDegree(double radian);
  double degreeToRadian(double degree);
}

/// Converts radians to degrees and vice versa using dart mathematic
class NativeAngleConverter implements AngleConverter {
  const NativeAngleConverter();

  @override
  double radianToDegree(double radian) {
    return radian * 180 / pi;
  }

  @override
  double degreeToRadian(double degree) {
    return degree * pi / 180;
  }
}

/// Converts radians to degrees and vice versa using H3's radsToDegs and degsToRads methods
class H3AngleConverter implements AngleConverter {
  const H3AngleConverter(H3 h3) : _h3 = h3;

  final H3 _h3;

  @override
  double radianToDegree(double radian) {
    return _h3.radsToDegs(radian);
  }

  @override
  double degreeToRadian(double degree) {
    return _h3.degsToRads(degree);
  }
}

import 'package:h3_web/h3_web.dart';

extension H3UnitsMapperExt on H3Units {
  String toH3JS() {
    switch (this) {
      case H3Units.m:
        return 'm';
      case H3Units.km:
        return 'km';
      case H3Units.rad:
        return 'rads';
    }
  }

  String toH3JSSquare() {
    switch (this) {
      case H3Units.m:
        return 'm2';
      case H3Units.km:
        return 'km2';
      case H3Units.rad:
        return 'rads2';
    }
  }
}

extension H3MetricUnitsMapperExt on H3MetricUnits {
  String toH3JS() {
    switch (this) {
      case H3MetricUnits.m:
        return 'm';
      case H3MetricUnits.km:
        return 'km';
    }
  }

  String toH3JSSquare() {
    switch (this) {
      case H3MetricUnits.m:
        return 'm2';
      case H3MetricUnits.km:
        return 'km2';
    }
  }
}

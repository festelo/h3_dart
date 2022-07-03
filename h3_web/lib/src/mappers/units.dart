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

extension H3AreaUnitsMapperExt on H3AreaUnits {
  String toH3JS() {
    switch (this) {
      case H3AreaUnits.m2:
        return 'm2';
      case H3AreaUnits.km2:
        return 'km2';
    }
  }
}

extension H3EdgeLengthUnitsMapperExt on H3EdgeLengthUnits {
  String toH3JS() {
    switch (this) {
      case H3EdgeLengthUnits.m:
        return 'm';
      case H3EdgeLengthUnits.km:
        return 'km';
    }
  }
}

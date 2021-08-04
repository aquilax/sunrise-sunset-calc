import 'dart:math';
import 'package:vector_math/vector_math.dart';

/// Result of SunriseSunset calculation
class SunriseSunsetResult {
  /// Construnctor method
  SunriseSunsetResult(this.sunrise, this.sunset);

  /// Time of the sunrise
  DateTime sunrise;

  /// Time of the sunset
  DateTime sunset;

  @override
  String toString() =>
      'sunrise: ${sunrise.toString()}, sunset: ${sunset.toString()}';
}

// Creates a vector with the seconds normalized to the range 0~1.
// seconds - The doubleber of seconds will be normalized to 1
// Return A vector with the seconds normalized to 0~1
List<double> _createSecondsNormalized(int seconds) =>
    List<double>.generate(seconds, (index) => index / (seconds - 1));

// Calculate Julian Day based on the formula: nDays+2415018.5+secondsNorm-UTCoff/24
// doubleDays - The doubleber of days calculated in the calculate function
// secondsNorm - Seconds normalized calculated by the createSecondsNormalized function
// utcOffset - UTC offset defined by the user
// Return Julian day slice
List<double> _calcJulianDay(
        int doubleDays, List<double> secondsNorm, Duration utcOffset) =>
    List<double>.generate(
        secondsNorm.length,
        (index) =>
            doubleDays +
            2415018.5 +
            secondsNorm[index] -
            utcOffset.inHours / 24.0);

// Calculate the Julian Century based on the formula: (julianDay - 2451545.0) / 36525.0
// julianDay - Julian day vector calculated by the calcJulianDay function
// Return Julian century slice
List<double> _calcJulianCentury(List<double> julianDay) =>
    List<double>.generate(
        julianDay.length, (index) => (julianDay[index] - 2451545.0) / 36525.0);

// Calculate the Geom Mean Long Sun in degrees based on the formula:
// 280.46646 + julianCentury * (36000.76983 + julianCentury * 0.0003032)
// julianCentury - Julian century calculated by the calcJulianCentury function
// Return The Geom Mean Long Sun slice
List<double> _calcGeomMeanLongSun(List<double> julianCentury) =>
    List<double>.generate(
        julianCentury.length,
        (index) =>
            (280.46646 +
                julianCentury[index] *
                    (36000.76983 + julianCentury[index] * 0.0003032)) %
            360);

// Calculate the Geom Mean Anom Sun in degrees based on the formula:
// 357.52911 + julianCentury * (35999.05029 - 0.0001537 * julianCentury)
// julianCentury - Julian century calculated by the calcJulianCentury function
// Return The Geom Mean Anom Sun slice
List<double> _calcGeomMeanAnomSun(List<double> julianCentury) =>
    List<double>.generate(
        julianCentury.length,
        (index) =>
            357.52911 +
            julianCentury[index] *
                (35999.05029 - 0.0001537 * julianCentury[index]));

// Calculate the Eccent Earth Orbit based on the formula:
// 0.016708634 - julianCentury * (0.000042037 + 0.0000001267 * julianCentury)
// julianCentury - Julian century calculated by the calcJulianCentury function
// Return The Eccent Earth Orbit slice
List<double> _calcEccentEarthOrbit(List<double> julianCentury) =>
    List<double>.generate(
        julianCentury.length,
        (index) =>
            0.016708634 -
            julianCentury[index] *
                (0.000042037 + 0.0000001267 * julianCentury[index]));

// Calculate the Sun Eq Ctr based on the formula:
// sin(deg2rad(geomMeanAnomSun))*(1.914602-julianCentury*(0.004817+0.000014*julianCentury))+sin(deg2rad(2*geomMeanAnomSun))*(0.019993-0.000101*julianCentury)+sin(deg2rad(3*geomMeanAnomSun))*0.000289;
// julianCentury - Julian century calculated by the calcJulianCentury function
// geomMeanAnomSun - Geom Mean Anom Sun calculated by the calcGeomMeanAnomSun function
// Return The Sun Eq Ctr slice
List<double> _calcSunEqCtr(
        List<double> julianCentury, List<double> geomMeanAnomSun) =>
    julianCentury.length != geomMeanAnomSun.length
        ? <double>[]
        : List<double>.generate(
            julianCentury.length,
            (index) =>
                sin(radians(geomMeanAnomSun[index])) *
                    (1.914602 -
                        julianCentury[index] *
                            (0.004817 + 0.000014 * julianCentury[index])) +
                sin(radians(2 * geomMeanAnomSun[index])) *
                    (0.019993 - 0.000101 * julianCentury[index]) +
                sin(radians(3 * geomMeanAnomSun[index])) * 0.000289);

// Calculate the Sun True Long in degrees based on the formula: sunEqCtr + geomMeanLongSun
// sunEqCtr - Sun Eq Ctr calculated by the calcSunEqCtr function
// geomMeanLongSun - Geom Mean Long Sun calculated by the calcGeomMeanLongSun function
// Return The Sun True Long slice
List<double> _calcSunTrueLong(
        List<double> sunEqCtr, List<double> geomMeanLongSun) =>
    sunEqCtr.length != geomMeanLongSun.length
        ? <double>[]
        : List<double>.generate(sunEqCtr.length,
            (index) => sunEqCtr[index] + geomMeanLongSun[index]);

// Calculate the Sun App Long in degrees based on the formula: sunTrueLong-0.00569-0.00478*sin(deg2rad(125.04-1934.136*julianCentury))
// sunTrueLong - Sun True Long calculated by the calcSunTrueLong function
// julianCentury - Julian century calculated by the calcJulianCentury function
// Return The Sun App Long slice
List<double> _calcSunAppLong(
        List<double> sunTrueLong, List<double> julianCentury) =>
    sunTrueLong.length != julianCentury.length
        ? <double>[]
        : List<double>.generate(
            sunTrueLong.length,
            (index) =>
                sunTrueLong[index] -
                0.00569 -
                0.00478 *
                    sin(radians(125.04 - 1934.136 * julianCentury[index])));

// Calculate the Mean Obliq Ecliptic in degrees based on the formula:
// 23+(26+((21.448-julianCentury*(46.815+julianCentury*(0.00059-julianCentury*0.001813))))/60)/60
// julianCentury - Julian century calculated by the calcJulianCentury function
// Return the Mean Obliq Ecliptic slice
List<double> _calcMeanObliqEcliptic(List<double> julianCentury) =>
    List<double>.generate(
        julianCentury.length,
        (index) =>
            23.0 +
            (26.0 +
                    (21.448 -
                            julianCentury[index] *
                                (46.815 +
                                    julianCentury[index] *
                                        (0.00059 -
                                            julianCentury[index] * 0.001813))) /
                        60.0) /
                60.0);

// Calculate the Obliq Corr in degrees based on the formula:
// meanObliqEcliptic+0.00256*cos(deg2rad(125.04-1934.136*julianCentury))
// meanObliqEcliptic - Mean Obliq Ecliptic calculated by the calcMeanObliqEcliptic function
// julianCentury - Julian century calculated by the calcJulianCentury function
// Return the Obliq Corr slice
List<double> _calcObliqCorr(
        List<double> meanObliqEcliptic, List<double> julianCentury) =>
    meanObliqEcliptic.length != julianCentury.length
        ? <double>[]
        : List<double>.generate(
            julianCentury.length,
            (index) =>
                meanObliqEcliptic[index] +
                0.00256 *
                    cos(radians(125.04 - 1934.136 * julianCentury[index])));

// Calculate the Sun Declination in degrees based on the formula:
// rad2deg(asin(sin(deg2rad(obliqCorr))*sin(deg2rad(sunAppLong))))
// obliqCorr - Obliq Corr calculated by the calcObliqCorr function
// sunAppLong - Sun App Long calculated by the calcSunAppLong function
// Return the sun declination slice
List<double> _calcSunDeclination(
        List<double> obliqCorr, List<double> sunAppLong) =>
    obliqCorr.length != sunAppLong.length
        ? <double>[]
        : List<double>.generate(
            obliqCorr.length,
            (index) => degrees(asin(sin(radians(obliqCorr[index])) *
                sin(radians(sunAppLong[index])))));

// Calculate the equation of time (minutes) based on the formula:
// 4*rad2deg(multiFactor*sin(2*deg2rad(geomMeanLongSun))-2*eccentEarthOrbit*sin(deg2rad(geomMeanAnomSun))+4*eccentEarthOrbit*multiFactor*sin(deg2rad(geomMeanAnomSun))*cos(2*deg2rad(geomMeanLongSun))-0.5*multiFactor*multiFactor*sin(4*deg2rad(geomMeanLongSun))-1.25*eccentEarthOrbit*eccentEarthOrbit*sin(2*deg2rad(geomMeanAnomSun)))
// multiFactor - The Multi Factor vector calculated in the calculate function
// geomMeanLongSun - The Geom Mean Long Sun vector calculated by the calcGeomMeanLongSun function
// eccentEarthOrbit - The Eccent Earth vector calculated by the calcEccentEarthOrbit function
// geomMeanAnomSun - The Geom Mean Anom Sun vector calculated by the calcGeomMeanAnomSun function
// Return the equation of time slice
List<double> _calcEquationOfTime(List<double> multiFactor, geomMeanLongSun,
    eccentEarthOrbit, geomMeanAnomSun) {
  if ((multiFactor.length != geomMeanLongSun.length) ||
      (multiFactor.length != eccentEarthOrbit.length) ||
      (multiFactor.length != geomMeanAnomSun.length)) {
    return <double>[];
  }

  return List<double>.generate(multiFactor.length, (index) {
    final a = multiFactor[index] * sin(2.0 * radians(geomMeanLongSun[index]));
    final b =
        2.0 * eccentEarthOrbit[index] * sin(radians(geomMeanAnomSun[index]));
    final c = 4.0 *
        eccentEarthOrbit[index] *
        multiFactor[index] *
        sin(radians(geomMeanAnomSun[index]));
    final d = cos(2.0 * radians(geomMeanLongSun[index]));
    final e = 0.5 *
        multiFactor[index] *
        multiFactor[index] *
        sin(4.0 * radians(geomMeanLongSun[index]));
    final f = 1.25 *
        eccentEarthOrbit[index] *
        eccentEarthOrbit[index] *
        sin(2.0 * radians(geomMeanAnomSun[index]));
    return 4.0 * degrees(a - b + c * d - e - f);
  });
}

// Calculate the HaSunrise in degrees based on the formula:
// rad2deg(acos(cos(deg2rad(90.833))/(cos(deg2rad(latitude))*cos(deg2rad(sunDeclination)))-tan(deg2rad(latitude))*tan(deg2rad(sunDeclination))))
//
// latitude - The latitude defined by the user
// sunDeclination - The Sun Declination calculated by the calcSunDeclination function
// Return the HaSunrise slice
List<double> _calcHaSunrise(double latitude, List<double> sunDeclination) =>
    List<double>.generate(
        sunDeclination.length,
        (index) => degrees(acos(cos(radians(90.833)) /
                (cos(radians(latitude)) * cos(radians(sunDeclination[index]))) -
            tan(radians(latitude)) * tan(radians(sunDeclination[index])))));

// Calculate the Solar Noon based on the formula:
// (720 - 4 * longitude - equationOfTime + utcOffset * 60) * 60
//
// longitude - The longitude is defined by the user
// equationOfTime - The Equation of Time slice is calculated by the calcEquationOfTime function
// utcOffset - The UTC offset is defined by the user
// Return the Solar Noon slice
List<double> _calcSolarNoon(
        double longitude, List<double> equationOfTime, int utcOffset) =>
    List<double>.generate(
        equationOfTime.length,
        (index) =>
            (720.0 -
                4.0 * longitude -
                equationOfTime[index] +
                utcOffset * 60.0) *
            60.0);

// Check if the latitude is valid. Range: -90 - 90
bool _checkLatitude(double latitude) => !(latitude < -90.0 || latitude > 90.0);

// Check if the longitude is valid. Range: -180 - 180
bool _checkLongitude(double longitude) =>
    !(longitude < -180.0 || longitude > 180.0);

// Check if the UTC offset is valid. Range: -12 - 14
bool _checkUtcOffset(int utcOffset) => !(utcOffset < -12.0 || utcOffset > 14.0);

// Check if the date is valid.
bool _checkDate(DateTime date) {
  final minDate = DateTime.utc(1900, 1, 1, 0, 0, 0, 0);
  final maxDate = DateTime.utc(2200, 1, 1, 0, 0, 0, 0);
  return !(date.compareTo(minDate) < 0 || date.compareTo(maxDate) > 0);
}

/// GetSunriseSunset function is responsible for calculating the apparent Sunrise and Sunset times.
/// If some parameter is wrong it will throw an error.
SunriseSunsetResult getSunriseSunset(
    double latitude, double longitude, int utcOffset, DateTime date) {
  // Check latitude
  if (!_checkLatitude(latitude)) {
    throw Exception('Invalid latitude');
  }
  // Check longitude
  if (!_checkLongitude(longitude)) {
    throw Exception('Invalid longitude');
  }
  // Check UTC offset
  if (!_checkUtcOffset(utcOffset)) {
    throw Exception('Invalid UTC offset');
  }
  // Check date
  if (!_checkDate(date)) {
    throw Exception('Invalid Date');
  }

  // The doubleber of days since 30/12/1899
  final since = DateTime.utc(1899, 12, 30);
  final doubleDays = date.difference(since);

  // Seconds of a full day 86400
  const seconds = 24 * 60 * 60;

  // Creates a vector that represents each second in the range 0~1
  final secondsNorm = _createSecondsNormalized(seconds);

  // Calculate Julian Day
  final julianDay =
      _calcJulianDay(doubleDays.inDays, secondsNorm, date.timeZoneOffset);

  // Calculate Julian Century
  final julianCentury = _calcJulianCentury(julianDay);

  // Geom Mean Long Sun (deg)
  final geomMeanLongSun = _calcGeomMeanLongSun(julianCentury);

  // Geom Mean Anom Sun (deg)
  final geomMeanAnomSun = _calcGeomMeanAnomSun(julianCentury);

  // Eccent Earth Orbit
  final eccentEarthOrbit = _calcEccentEarthOrbit(julianCentury);

  // Sun Eq of Ctr
  final sunEqCtr = _calcSunEqCtr(julianCentury, geomMeanAnomSun);

  // Sun True Long (deg)
  final sunTrueLong = _calcSunTrueLong(sunEqCtr, geomMeanLongSun);

  // Sun App Long (deg)
  final sunAppLong = _calcSunAppLong(sunTrueLong, julianCentury);

  // Mean Obliq Ecliptic (deg)
  final meanObliqEcliptic = _calcMeanObliqEcliptic(julianCentury);

  // Obliq Corr (deg)
  final obliqCorr = _calcObliqCorr(meanObliqEcliptic, julianCentury);

  // Sun Declin (deg)
  final sunDeclination = _calcSunDeclination(obliqCorr, sunAppLong);

  // var y
  // final multiFactor = <double>[];
  // for (var index = 0; index < obliqCorr.length; index++) {
  //   final temp = tan(radians(obliqCorr[index] / 2.0)) *
  //       tan(radians(obliqCorr[index] / 2.0));
  //   multiFactor.add(temp);
  // }
  final multiFactor = List<double>.generate(obliqCorr.length,
      (index) => ((n) => n * n)(tan(radians(obliqCorr[index] / 2.0))));

  // Eq of Time (minutes)
  final equationOfTime = _calcEquationOfTime(
      multiFactor, geomMeanLongSun, eccentEarthOrbit, geomMeanAnomSun);

  // HA Sunrise (deg)
  final haSunrise = _calcHaSunrise(latitude, sunDeclination);

  // Solar Noon (LST)
  final solarNoon = _calcSolarNoon(longitude, equationOfTime, utcOffset);

  // Sunrise and Sunset Times (LST)
  var minSunrise = 86400.0;
  var sunriseSeconds = -1;
  var minSunset = 86400.0;
  var sunsetSeconds = -1;
  var a;
  var b;

  for (var index = 0; index < solarNoon.length; index++) {
    a = (haSunrise[index] * 4.0 * 60.0).round();
    b = seconds * secondsNorm[index];

    var sunrise = (solarNoon[index] - a - b).abs();
    var sunset = (solarNoon[index] + a - b).abs();

    if (sunrise < minSunrise) {
      minSunrise = sunrise;
      sunriseSeconds = index;
    }
    if (sunset < minSunset) {
      minSunset = sunset;
      sunsetSeconds = index;
    }
  }

  // Convert the seconds to time
  final defaultTime = DateTime.utc(date.year, date.month, date.day, 0, 0, 0);
  return SunriseSunsetResult(defaultTime.add(Duration(seconds: sunriseSeconds)),
      defaultTime.add(Duration(seconds: sunsetSeconds)));
}

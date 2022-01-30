import 'sunrise_sunset_calc_result.dart';
import 'sunrise_sunset_calc_common.dart';

// Creates a vector with the seconds normalized to the range 0~1.
// seconds - The doubleber of seconds will be normalized to 1
// Return A vector with the seconds normalized to 0~1
List<double> _createSecondsNormalized(int seconds) =>
    List<double>.generate(seconds, (index) => index / (seconds - 1));

/// GetSunriseSunset function is responsible for calculating the apparent Sunrise and Sunset times.
/// If some parameter is wrong it will throw an error.
SunriseSunsetResult getSunriseSunset(
    double latitude, double longitude, int utcOffset, DateTime date) {
  // Check latitude
  if (!checkLatitude(latitude)) {
    throw Exception('Invalid latitude');
  }
  // Check longitude
  if (!checkLongitude(longitude)) {
    throw Exception('Invalid longitude');
  }
  // Check UTC offset
  if (!checkUtcOffset(utcOffset)) {
    throw Exception('Invalid UTC offset');
  }
  // Check date
  if (!checkDate(date)) {
    throw Exception('Invalid Date');
  }

  // The doubleber of days since 30/12/1899
  final since = DateTime.utc(1899, 12, 30);
  final doubleDays = date.difference(since).inDays;

  // Seconds of a full day 86400
  const seconds = 24 * 60 * 60;
  final utcOffsetHours = date.timeZoneOffset.inHours / 24;

  // Creates a vector that represents each second in the range 0~1
  final secondsNorm = _createSecondsNormalized(seconds);

  // Calculate Julian Day
  final julianDay = secondsNorm
      .map((seconds) => calcJulianDay(doubleDays, seconds, utcOffsetHours));

  // Calculate Julian Century
  final julianCentury = julianDay.map(calcJulianCentury).toList();

  // Geom Mean Long Sun (deg)
  final geomMeanLongSun = julianCentury.map(calcGeomMeanLongSun).toList();

  // Geom Mean Anom Sun (deg)
  final geomMeanAnomSun = julianCentury.map(calcGeomMeanAnomSun).toList();

  // Eccent Earth Orbit
  final eccentEarthOrbit = julianCentury.map(calcEccentEarthOrbit).toList();

  // Sun Eq of Ctr
  final sunEqCtr = List<double>.generate(julianCentury.length,
      (index) => calcSunEqCtr(julianCentury[index], geomMeanAnomSun[index]));

  // Sun True Long (deg)
  final sunTrueLong = List<double>.generate(sunEqCtr.length,
      (index) => calcSunTrueLong(sunEqCtr[index], geomMeanLongSun[index]));

  // Sun App Long (deg)
  final sunAppLong = List<double>.generate(sunTrueLong.length,
      (index) => calcSunAppLong(sunTrueLong[index], julianCentury[index]));

  // Mean Obliq Ecliptic (deg)
  final meanObliqEcliptic = julianCentury.map(calcMeanObliqEcliptic).toList();

  // Obliq Corr (deg)
  final obliqCorr = List<double>.generate(julianCentury.length,
      (index) => calcObliqCorr(meanObliqEcliptic[index], julianCentury[index]));

  // Sun Declin (deg)
  final sunDeclination = List<double>.generate(obliqCorr.length,
      (index) => calcSunDeclination(obliqCorr[index], sunAppLong[index]));

  final multiFactor = obliqCorr.map(calcMultiFactoror).toList();

  // Eq of Time (minutes)
  final equationOfTime = List<double>.generate(
      multiFactor.length,
      (index) => calcEquationOfTime(multiFactor[index], geomMeanLongSun[index],
          eccentEarthOrbit[index], geomMeanAnomSun[index])).toList();

  // HA Sunrise (deg)
  final haSunrise = List<double>.generate(sunDeclination.length,
      (index) => calcHaSunrise(latitude, sunDeclination[index]));

  // Solar Noon (LST)
  final solarNoon = List<double>.generate(equationOfTime.length,
      (index) => calcSolarNoon(longitude, equationOfTime[index], utcOffset));

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

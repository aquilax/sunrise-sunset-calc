import 'package:async/async.dart';
import 'sunrise_sunset_calc_result.dart';
import 'sunrise_sunset_calc_common.dart';

// TODO: Use Function.apply if it ever gets faster

// Creates a vector with the seconds normalized to the range 0~1.
// seconds - The doubleber of seconds will be normalized to 1
// Return A vector with the seconds normalized to 0~1
Stream<double> _createSecondsNormalized(int seconds) async* {
  for (var index = 0; index < seconds; index++) {
    yield index / (seconds - 1);
  }
}

class _Aggregator {
  double minSunrise = 86400.0;
  double minSunset = 86400.0;
  int sunriseSeconds = -1;
  int sunsetSeconds = -1;
  int index = 0;
}

/// GetSunriseSunset function is responsible for calculating the apparent Sunrise and Sunset times.
/// If some parameter is wrong it will throw an error.
Future<SunriseSunsetResult> getSunriseSunsetAsync(
    double latitude, double longitude, int utcOffset, DateTime date) async {
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
  const seconds = secondsInADay;
  final utcOffsetHours = date.timeZoneOffset.inHours / 24;

  // Creates a vector that represents each second in the range 0~1
  final secondsNorm = _createSecondsNormalized(seconds).asBroadcastStream();

  // Calculate Julian Day
  final julianDay = secondsNorm
      .map((second) => calcJulianDay(doubleDays, second, utcOffsetHours));

  // Calculate Julian Century
  final julianCentury = julianDay.map(calcJulianCentury).asBroadcastStream();

  // Geom Mean Long Sun (deg)
  final geomMeanLongSun =
      julianCentury.map(calcGeomMeanLongSun).asBroadcastStream();

  // Geom Mean Anom Sun (deg)
  final geomMeanAnomSun =
      julianCentury.map(calcGeomMeanAnomSun).asBroadcastStream();

  // Eccent Earth Orbit
  final eccentEarthOrbit = julianCentury.map(calcEccentEarthOrbit);

  // Sun Eq of Ctr
  final sunEqCtr = StreamZip([julianCentury, geomMeanAnomSun])
      .map<double>((event) => calcSunEqCtr(event[0], event[1]));

  // Sun True Long (deg)
  final sunTrueLong = StreamZip([sunEqCtr, geomMeanLongSun])
      .map<double>((event) => calcSunTrueLong(event[0], event[1]));

  // Sun App Long (deg)
  final sunAppLong = StreamZip([sunTrueLong, julianCentury])
      .map<double>((event) => calcSunAppLong(event[0], event[1]));

  // Mean Obliq Ecliptic (deg)
  final meanObliqEcliptic = julianCentury.map(calcMeanObliqEcliptic);

  // Obliq Corr (deg)
  final obliqCorr = StreamZip([meanObliqEcliptic, julianCentury])
      .map<double>((event) => calcObliqCorr(event[0], event[1]));

  // Sun Declin (deg)
  final sunDeclination = StreamZip([obliqCorr, sunAppLong])
      .map<double>((event) => calcSunDeclination(event[0], event[1]));

  final multiFactor = obliqCorr.map(calcMultiFactoror);

  // Eq of Time (minutes)
  final equationOfTime = StreamZip<double>([
    multiFactor,
    geomMeanLongSun,
    eccentEarthOrbit,
    geomMeanAnomSun
  ]).map<double>(
      (event) => calcEquationOfTime(event[0], event[1], event[2], event[3]));

  // HA Sunrise (deg)
  final haSunrise = sunDeclination
      .map((sunDeclination) => calcHaSunrise(latitude, sunDeclination));

  // Solar Noon (LST)
  final solarNoonStream = equationOfTime.map(
      (equationOfTime) => calcSolarNoon(longitude, equationOfTime, utcOffset));

  _Aggregator getResult(_Aggregator aggregator, List<double> element) {
    final secondsNormVal = element[0];
    final haSunriseVal = element[1];
    final solarNoonVal = element[2];

    final a = (haSunriseVal * 4.0 * 60.0).round();
    final b = seconds * secondsNormVal;

    final sunrise = (solarNoonVal - a - b).abs();
    final sunset = (solarNoonVal + a - b).abs();

    if (sunrise < aggregator.minSunrise) {
      aggregator.minSunrise = sunrise;
      aggregator.sunriseSeconds = aggregator.index;
    }
    if (sunset < aggregator.minSunset) {
      aggregator.minSunset = sunset;
      aggregator.sunsetSeconds = aggregator.index;
    }
    aggregator.index += 1;
    return aggregator;
  }

  final result = await StreamZip([secondsNorm, haSunrise, solarNoonStream])
      .fold(_Aggregator(), getResult);

  // Convert the seconds to time
  final defaultTime = DateTime.utc(date.year, date.month, date.day, 0, 0, 0);
  return SunriseSunsetResult(
      defaultTime.add(Duration(seconds: result.sunriseSeconds)),
      defaultTime.add(Duration(seconds: result.sunsetSeconds)));
}

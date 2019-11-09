/// Checks if you are awesome. Spoiler: you are.
import 'dart:math';

/// Result of SunriseSunset calculation
class SunriseSunsetResult {
  DateTime sunrise;
  DateTime sunset;

  SunriseSunsetResult(this.sunrise, this.sunset);
  String toString() => "sunrise: ${this.sunrise.toString()}, sunset: ${this.sunset.toString()}";
}

// Convert radians to degrees
num rad2deg(num rad) => rad * (180.0 / pi);

// Convert degrees to radians
num deg2rad(num deg) => deg * (pi / 180.0);

// Convert each value to the absolute value
List<num> abs(List<num> list) => list.map((d) => d.abs()).toList();

// Find the index of the minimum value
int minIndex(List<num> list) {
  if (list.isEmpty) {
    return -1;
  }
  num min = list[0];
  int minIndex = 0;
  for (int index = 0; index < list.length; index++) {
    if (list[index] < min) {
      min = list[index];
      minIndex = index;
    }
  }
  return minIndex;
}

// Creates a vector with the seconds normalized to the range 0~1.
// seconds - The number of seconds will be normalized to 1
// Return A vector with the seconds normalized to 0~1
List<num> _createSecondsNormalized(int seconds) {
  List<num> vector = [];
  for (int index = 0; index < seconds; index++) {
    vector.add(index / (seconds - 1));
  }
  return vector;
}

// Calculate Julian Day based on the formula: nDays+2415018.5+secondsNorm-UTCoff/24
// numDays - The number of days calculated in the calculate function
// secondsNorm - Seconds normalized calculated by the createSecondsNormalized function
// utcOffset - UTC offset defined by the user
// Return Julian day slice
List<num> _calcJulianDay(
    int numDays, List<num> secondsNorm, Duration utcOffset) {
  List<num> julianDay = [];
  for (num index = 0; index < secondsNorm.length; index++) {
    num temp =
        numDays + 2415018.5 + secondsNorm[index] - utcOffset.inHours / 24.0;
    julianDay.add(temp);
  }
  return julianDay;
}

// Calculate the Julian Century based on the formula: (julianDay - 2451545.0) / 36525.0
// julianDay - Julian day vector calculated by the calcJulianDay function
// Return Julian century slice
List<num> _calcJulianCentury(List<num> julianDay) {
  List<num> julianCentury = [];
  for (int index = 0; index < julianDay.length; index++) {
    num temp = (julianDay[index] - 2451545.0) / 36525.0;
    julianCentury.add(temp);
  }
  return julianCentury;
}

// Calculate the Geom Mean Long Sun in degrees based on the formula: 280.46646 + julianCentury * (36000.76983 + julianCentury * 0.0003032)
// julianCentury - Julian century calculated by the calcJulianCentury function
// Return The Geom Mean Long Sun slice
List<num> _calcGeomMeanLongSun(List<num> julianCentury) {
  List<num> geomMeanLongSun = [];
  for (int index = 0; index < julianCentury.length; index++) {
    num a = 280.46646 +
        julianCentury[index] *
            (36000.76983 + julianCentury[index] * 0.0003032);
    geomMeanLongSun.add(a % 360);
  }
  return geomMeanLongSun;
}

// Calculate the Geom Mean Anom Sun in degrees based on the formula: 357.52911 + julianCentury * (35999.05029 - 0.0001537 * julianCentury)
// julianCentury - Julian century calculated by the calcJulianCentury function
// Return The Geom Mean Anom Sun slice
List<num> _calcGeomMeanAnomSun(List<num> julianCentury) {
  List<num> geomMeanAnomSun = [];
  for (int index = 0; index < julianCentury.length; index++) {
    num temp = 357.52911 +
        julianCentury[index] *
            (35999.05029 - 0.0001537 * julianCentury[index]);
    geomMeanAnomSun.add(temp);
  }
  return geomMeanAnomSun;
}

// Calculate the Eccent Earth Orbit based on the formula: 0.016708634 - julianCentury * (0.000042037 + 0.0000001267 * julianCentury)
// julianCentury - Julian century calculated by the calcJulianCentury function
// Return The Eccent Earth Orbit slice
List<num> _calcEccentEarthOrbit(List<num> julianCentury) {
  List<num> eccentEarthOrbit = [];
  for (int index = 0; index < julianCentury.length; index++) {
    num temp = 0.016708634 -
        julianCentury[index] *
            (0.000042037 + 0.0000001267 * julianCentury[index]);
    eccentEarthOrbit.add(temp);
  }
  return eccentEarthOrbit;
}

// Calculate the Sun Eq Ctr based on the formula: sin(deg2rad(geomMeanAnomSun))*(1.914602-julianCentury*(0.004817+0.000014*julianCentury))+sin(deg2rad(2*geomMeanAnomSun))*(0.019993-0.000101*julianCentury)+sin(deg2rad(3*geomMeanAnomSun))*0.000289;
// julianCentury - Julian century calculated by the calcJulianCentury function
// geomMeanAnomSun - Geom Mean Anom Sun calculated by the calcGeomMeanAnomSun function
// Return The Sun Eq Ctr slice
List<num> _calcSunEqCtr(
    List<num> julianCentury, List<num> geomMeanAnomSun) {
  List<num> sunEqCtr = [];
  if (julianCentury.length != geomMeanAnomSun.length) {
    return sunEqCtr;
  }

  for (int index = 0; index < julianCentury.length; index++) {
    num temp = sin(deg2rad(geomMeanAnomSun[index])) *
            (1.914602 -
                julianCentury[index] *
                    (0.004817 + 0.000014 * julianCentury[index])) +
        sin(deg2rad(2 * geomMeanAnomSun[index])) *
            (0.019993 - 0.000101 * julianCentury[index]) +
        sin(deg2rad(3 * geomMeanAnomSun[index])) * 0.000289;
    sunEqCtr.add(temp);
  }
  return sunEqCtr;
}

// Calculate the Sun True Long in degrees based on the formula: sunEqCtr + geomMeanLongSun
// sunEqCtr - Sun Eq Ctr calculated by the calcSunEqCtr function
// geomMeanLongSun - Geom Mean Long Sun calculated by the calcGeomMeanLongSun function
// Return The Sun True Long slice
List<num> _calcSunTrueLong(
    List<num> sunEqCtr, List<num> geomMeanLongSun) {
  List<num> sunTrueLong = [];
  if (sunEqCtr.length != geomMeanLongSun.length) {
    return sunTrueLong;
  }

  for (int index = 0; index < sunEqCtr.length; index++) {
    num temp = sunEqCtr[index] + geomMeanLongSun[index];
    sunTrueLong.add(temp);
  }
  return sunTrueLong;
}

// Calculate the Sun App Long in degrees based on the formula: sunTrueLong-0.00569-0.00478*sin(deg2rad(125.04-1934.136*julianCentury))
// sunTrueLong - Sun True Long calculated by the calcSunTrueLong function
// julianCentury - Julian century calculated by the calcJulianCentury function
// Return The Sun App Long slice
List<num> _calcSunAppLong(
    List<num> sunTrueLong, List<num> julianCentury) {
  List<num> sunAppLong = [];
  if (sunTrueLong.length != julianCentury.length) {
    return sunAppLong;
  }

  for (int index = 0; index < sunTrueLong.length; index++) {
    num temp = sunTrueLong[index] -
        0.00569 -
        0.00478 * sin(deg2rad(125.04 - 1934.136 * julianCentury[index]));
    sunAppLong.add(temp);
  }
  return sunAppLong;
}

// Calculate the Mean Obliq Ecliptic in degrees based on the formula: 23+(26+((21.448-julianCentury*(46.815+julianCentury*(0.00059-julianCentury*0.001813))))/60)/60
// julianCentury - Julian century calculated by the calcJulianCentury function
// Return the Mean Obliq Ecliptic slice
List<num> _calcMeanObliqEcliptic(List<num> julianCentury) {
  List<num> meanObliqEcliptic = [];
  for (int index = 0; index < julianCentury.length; index++) {
    num temp = 23.0 +
        (26.0 +
                (21.448 -
                        julianCentury[index] *
                            (46.815 +
                                julianCentury[index] *
                                    (0.00059 -
                                        julianCentury[index] * 0.001813))) /
                    60.0) /
            60.0;
    meanObliqEcliptic.add(temp);
  }
  return meanObliqEcliptic;
}

// Calculate the Obliq Corr in degrees based on the formula: meanObliqEcliptic+0.00256*cos(deg2rad(125.04-1934.136*julianCentury))
// meanObliqEcliptic - Mean Obliq Ecliptic calculated by the calcMeanObliqEcliptic function
// julianCentury - Julian century calculated by the calcJulianCentury function
// Return the Obliq Corr slice
List<num> _calcObliqCorr(
    List<num> meanObliqEcliptic, List<num> julianCentury) {
  List<num> obliqCorr = [];
  if (meanObliqEcliptic.length != julianCentury.length) {
    return obliqCorr;
  }

  for (int index = 0; index < julianCentury.length; index++) {
    num temp = meanObliqEcliptic[index] +
        0.00256 * cos(deg2rad(125.04 - 1934.136 * julianCentury[index]));
    obliqCorr.add(temp);
  }
  return obliqCorr;
}

// Calculate the Sun Declination in degrees based on the formula: rad2deg(asin(sin(deg2rad(obliqCorr))*sin(deg2rad(sunAppLong))))
// obliqCorr - Obliq Corr calculated by the calcObliqCorr function
// sunAppLong - Sun App Long calculated by the calcSunAppLong function
// Return the sun declination slice
List<num> _calcSunDeclination(
    List<num> obliqCorr, List<num> sunAppLong) {
  List<num> sunDeclination = [];
  if (obliqCorr.length != sunAppLong.length) {
    return sunDeclination;
  }

  for (int index = 0; index < obliqCorr.length; index++) {
    num temp = rad2deg(asin(
        sin(deg2rad(obliqCorr[index])) * sin(deg2rad(sunAppLong[index]))));
    sunDeclination.add(temp);
  }
  return sunDeclination;
}

// Calculate the equation of time (minutes) based on the formula:
// 4*rad2deg(multiFactor*sin(2*deg2rad(geomMeanLongSun))-2*eccentEarthOrbit*sin(deg2rad(geomMeanAnomSun))+4*eccentEarthOrbit*multiFactor*sin(deg2rad(geomMeanAnomSun))*cos(2*deg2rad(geomMeanLongSun))-0.5*multiFactor*multiFactor*sin(4*deg2rad(geomMeanLongSun))-1.25*eccentEarthOrbit*eccentEarthOrbit*sin(2*deg2rad(geomMeanAnomSun)))
// multiFactor - The Multi Factor vector calculated in the calculate function
// geomMeanLongSun - The Geom Mean Long Sun vector calculated by the calcGeomMeanLongSun function
// eccentEarthOrbit - The Eccent Earth vector calculated by the calcEccentEarthOrbit function
// geomMeanAnomSun - The Geom Mean Anom Sun vector calculated by the calcGeomMeanAnomSun function
// Return the equation of time slice
List<num> _calcEquationOfTime(List<num> multiFactor, geomMeanLongSun,
    eccentEarthOrbit, geomMeanAnomSun) {
  List<num> equationOfTime = [];
  if ((multiFactor.length != geomMeanLongSun.length) ||
      (multiFactor.length != eccentEarthOrbit.length) ||
      (multiFactor.length != geomMeanAnomSun.length)) {
    return equationOfTime;
  }

  for (int index = 0; index < multiFactor.length; index++) {
    num a = multiFactor[index] * sin(2.0 * deg2rad(geomMeanLongSun[index]));
    num b =
        2.0 * eccentEarthOrbit[index] * sin(deg2rad(geomMeanAnomSun[index]));
    num c = 4.0 *
        eccentEarthOrbit[index] *
        multiFactor[index] *
        sin(deg2rad(geomMeanAnomSun[index]));
    num d = cos(2.0 * deg2rad(geomMeanLongSun[index]));
    num e = 0.5 *
        multiFactor[index] *
        multiFactor[index] *
        sin(4.0 * deg2rad(geomMeanLongSun[index]));
    num f = 1.25 *
        eccentEarthOrbit[index] *
        eccentEarthOrbit[index] *
        sin(2.0 * deg2rad(geomMeanAnomSun[index]));
    num temp = 4.0 * rad2deg(a - b + c * d - e - f);
    equationOfTime.add(temp);
  }
  return equationOfTime;
}

// Calculate the HaSunrise in degrees based on the formula: rad2deg(acos(cos(deg2rad(90.833))/(cos(deg2rad(latitude))*cos(deg2rad(sunDeclination)))-tan(deg2rad(latitude))*tan(deg2rad(sunDeclination))))
// latitude - The latitude defined by the user
// sunDeclination - The Sun Declination calculated by the calcSunDeclination function
// Return the HaSunrise slice
List<num> _calcHaSunrise(num latitude, List<num> sunDeclination) {
  List<num> haSunrise = [];
  for (int index = 0; index < sunDeclination.length; index++) {
    num temp = rad2deg(acos(cos(deg2rad(90.833)) /
            (cos(deg2rad(latitude)) * cos(deg2rad(sunDeclination[index]))) -
        tan(deg2rad(latitude)) * tan(deg2rad(sunDeclination[index]))));
    haSunrise.add(temp);
  }
  return haSunrise;
}

// Calculate the Solar Noon based on the formula: (720 - 4 * longitude - equationOfTime + utcOffset * 60) * 60
// longitude - The longitude is defined by the user
// equationOfTime - The Equation of Time slice is calculated by the calcEquationOfTime function
// utcOffset - The UTC offset is defined by the user
// Return the Solar Noon slice
List<num> _calcSolarNoon(
    num longitude, List<num> equationOfTime, int utcOffset) {
  List<num> solarNoon = [];
  for (int index = 0; index < equationOfTime.length; index++) {
    num temp =
        (720.0 - 4.0 * longitude - equationOfTime[index] + utcOffset * 60.0) *
            60.0;
    solarNoon.add(temp);
  }
  return solarNoon;
}

// Check if the latitude is valid. Range: -90 - 90
bool _checkLatitude(num latitude) =>
    !(latitude < -90.0 || latitude > 90.0);

// Check if the longitude is valid. Range: -180 - 180
bool _checkLongitude(num longitude) =>
    !(longitude < -180.0 || longitude > 180.0);

// Check if the UTC offset is valid. Range: -12 - 14
bool _checkUtcOffset(num utcOffset) =>
    !(utcOffset < -12.0 || utcOffset > 14.0);

// Check if the date is valid.
bool _checkDate(DateTime date) {
  DateTime minDate = DateTime.utc(1900, 1, 1, 0, 0, 0, 0);
  DateTime maxDate = DateTime.utc(2200, 1, 1, 0, 0, 0, 0);
  return !(date.compareTo(minDate) < 0 || date.compareTo(maxDate) > 0);
}


// GetSunriseSunset function is responsible for calculate the apparent Sunrise and Sunset times.
// If some parameter is wrong it will return an error.
SunriseSunsetResult getSunriseSunset(
    num latitude, longitude, int utcOffset, DateTime date) {
  // Check latitude
  if (!_checkLatitude(latitude)) {
    throw Exception("Invalid latitude");
  }
  // Check longitude
  if (!_checkLongitude(longitude)) {
    throw Exception("Invalid longitude");
  }
  // Check UTC offset
  if (!_checkUtcOffset(utcOffset)) {
    throw Exception("Invalid UTC offset");
  }
  // Check date
  if (!_checkDate(date)) {
    throw Exception("Invalid Date");
  }

  // The number of days since 30/12/1899
  DateTime since = DateTime.utc(1899, 12, 30);
  Duration numDays = date.difference(since);

  // Seconds of a full day 86400
  int seconds = 24 * 60 * 60;

  // Creates a vector that represents each second in the range 0~1
  List<num> secondsNorm = _createSecondsNormalized(seconds);

  // Calculate Julian Day
  List<num> julianDay =
      _calcJulianDay(numDays.inDays, secondsNorm, date.timeZoneOffset);

  // Calculate Julian Century
  List<num> julianCentury = _calcJulianCentury(julianDay);

  // Geom Mean Long Sun (deg)
  List<num> geomMeanLongSun = _calcGeomMeanLongSun(julianCentury);

  // Geom Mean Anom Sun (deg)
  List<num> geomMeanAnomSun = _calcGeomMeanAnomSun(julianCentury);

  // Eccent Earth Orbit
  List<num> eccentEarthOrbit = _calcEccentEarthOrbit(julianCentury);

  // Sun Eq of Ctr
  List<num> sunEqCtr = _calcSunEqCtr(julianCentury, geomMeanAnomSun);

  // Sun True Long (deg)
  List<num> sunTrueLong = _calcSunTrueLong(sunEqCtr, geomMeanLongSun);

  // Sun App Long (deg)
  List<num> sunAppLong = _calcSunAppLong(sunTrueLong, julianCentury);

  // Mean Obliq Ecliptic (deg)
  List<num> meanObliqEcliptic = _calcMeanObliqEcliptic(julianCentury);

  // Obliq Corr (deg)
  List<num> obliqCorr = _calcObliqCorr(meanObliqEcliptic, julianCentury);

  // Sun Declin (deg)
  List<num> sunDeclination = _calcSunDeclination(obliqCorr, sunAppLong);

  // var y
  List<num> multiFactor = [];
  for (int index = 0; index < obliqCorr.length; index++) {
    num temp = tan(deg2rad(obliqCorr[index] / 2.0)) *
        tan(deg2rad(obliqCorr[index] / 2.0));
    multiFactor.add(temp);
  }

  // Eq of Time (minutes)
  List<num> equationOfTime = _calcEquationOfTime(
      multiFactor, geomMeanLongSun, eccentEarthOrbit, geomMeanAnomSun);

  // HA Sunrise (deg)
  List<num> haSunrise = _calcHaSunrise(latitude, sunDeclination);

  // Solar Noon (LST)
  List<num> solarNoon = _calcSolarNoon(longitude, equationOfTime, utcOffset);

  // Sunrise and Sunset Times (LST)
  List<num> tempSunrise = [];
  List<num> tempSunset = [];

  for (int index = 0; index < solarNoon.length; index++) {
    tempSunrise.add(solarNoon[index] -
        (haSunrise[index] * 4.0 * 60.0).round() -
        (seconds) * secondsNorm[index]);
    tempSunset.add(solarNoon[index] +
        (haSunrise[index] * 4.0 * 60.0).round() -
        (seconds) * secondsNorm[index]);
  }

  // Get the sunrise and sunset in seconds
  int sunriseSeconds = minIndex(abs(tempSunrise));
  int sunsetSeconds = minIndex(abs(tempSunset));

  // Convert the seconds to time
  DateTime defaultTime =
      DateTime.utc(date.year, date.month, date.day, 0, 0, 0);
  return SunriseSunsetResult(
      defaultTime.add(Duration(seconds: sunriseSeconds)),
      defaultTime.add(Duration(seconds: sunsetSeconds)));
}

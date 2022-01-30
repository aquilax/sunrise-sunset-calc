import 'dart:math';
import 'package:vector_math/vector_math.dart';

/// Calculate Julian Day based on the formula: nDays+2415018.5+secondsNorm-UTCoff/24
/// [doubleDays] - The doubleber of days calculated in the calculate function
/// [secondsNorm] - Seconds normalized calculated by the createSecondsNormalized function
/// [utcOffset] - UTC offset defined by the user
/// Return Julian day
double calcJulianDay(int doubleDays, double secondsNorm, double utcOffset) =>
    doubleDays + 2415018.5 + secondsNorm - utcOffset;

/// Calculate the Julian Century based on the formula: (julianDay - 2451545.0) / 36525.0
/// [julianDay] - Julian day calculated by the calcJulianDay function
/// Return Julian century
double calcJulianCentury(double julianDay) => (julianDay - 2451545.0) / 36525.0;

/// Calculate the Geom Mean Long Sun in degrees based on the formula:
/// 280.46646 + julianCentury * (36000.76983 + julianCentury * 0.0003032)
/// [julianCentury] - Julian century calculated by the calcJulianCentury function
/// Return The Geom Mean Long Sun
double calcGeomMeanLongSun(double julianCentury) =>
    (280.46646 + julianCentury * (36000.76983 + julianCentury * 0.0003032)) %
    360;

/// Calculate the Geom Mean Anom Sun in degrees based on the formula:
/// 357.52911 + julianCentury * (35999.05029 - 0.0001537 * julianCentury)
/// [julianCentury] - Julian century calculated by the calcJulianCentury function
/// Return The Geom Mean Anom Sun
double calcGeomMeanAnomSun(double julianCentury) =>
    357.52911 + julianCentury * (35999.05029 - 0.0001537 * julianCentury);

/// Calculate the Eccent Earth Orbit based on the formula:
/// 0.016708634 - julianCentury * (0.000042037 + 0.0000001267 * julianCentury)
/// [julianCentury] - Julian century calculated by the calcJulianCentury function
/// Return The Eccent Earth Orbit
double calcEccentEarthOrbit(double julianCentury) =>
    0.016708634 - julianCentury * (0.000042037 + 0.0000001267 * julianCentury);

/// Calculate the Sun Eq Ctr based on the formula:
/// sin(deg2rad(geomMeanAnomSun))*(1.914602-julianCentury*(0.004817+0.000014*julianCentury))+sin(deg2rad(2*geomMeanAnomSun))*(0.019993-0.000101*julianCentury)+sin(deg2rad(3*geomMeanAnomSun))*0.000289;
/// [julianCentury] - Julian century calculated by the calcJulianCentury function
/// [geomMeanAnomSun] - Geom Mean Anom Sun calculated by the calcGeomMeanAnomSun function
/// Return The Sun Eq Ctr
double calcSunEqCtr(double julianCentury, double geomMeanAnomSun) =>
    (sin(radians(geomMeanAnomSun)) *
            (1.914602 - julianCentury * (0.004817 + 0.000014 * julianCentury)) +
        sin(radians(2 * geomMeanAnomSun)) *
            (0.019993 - 0.000101 * julianCentury) +
        sin(radians(3 * geomMeanAnomSun)) * 0.000289);

/// Calculate the Sun True Long in degrees based on the formula: sunEqCtr + geomMeanLongSun
/// [sunEqCtr] - Sun Eq Ctr calculated by the calcSunEqCtr function
/// [geomMeanLongSun] - Geom Mean Long Sun calculated by the calcGeomMeanLongSun function
/// Return The Sun True Long
double calcSunTrueLong(double sunEqCtr, double geomMeanLongSun) =>
    sunEqCtr + geomMeanLongSun;

/// Calculate the Sun App Long in degrees based on the formula: sunTrueLong-0.00569-0.00478*sin(deg2rad(125.04-1934.136*julianCentury))
/// sunTrueLong - Sun True Long calculated by the calcSunTrueLong function
/// [julianCentury] - Julian century calculated by the calcJulianCentury function
/// Return The Sun App Long
double calcSunAppLong(double sunTrueLong, double julianCentury) =>
    sunTrueLong -
    0.00569 -
    0.00478 * sin(radians(125.04 - 1934.136 * julianCentury));

/// Calculate the Mean Obliq Ecliptic in degrees based on the formula:
/// 23+(26+((21.448-julianCentury*(46.815+julianCentury*(0.00059-julianCentury*0.001813))))/60)/60
/// [julianCentury] - Julian century calculated by the calcJulianCentury function
/// Return the Mean Obliq Ecliptic
double calcMeanObliqEcliptic(double julianCentury) =>
    23.0 +
    (26.0 +
            (21.448 -
                    julianCentury *
                        (46.815 +
                            julianCentury *
                                (0.00059 - julianCentury * 0.001813))) /
                60.0) /
        60.0;

/// Calculate the Obliq Corr in degrees based on the formula:
/// meanObliqEcliptic+0.00256*cos(deg2rad(125.04-1934.136*julianCentury))
/// [meanObliqEcliptic] - Mean Obliq Ecliptic calculated by the calcMeanObliqEcliptic function
/// [julianCentury] - Julian century calculated by the calcJulianCentury function
/// Return the Obliq Corr
double calcObliqCorr(double meanObliqEcliptic, double julianCentury) =>
    meanObliqEcliptic +
    0.00256 * cos(radians(125.04 - 1934.136 * julianCentury));

/// Calculate the Sun Declination in degrees based on the formula:
/// rad2deg(asin(sin(deg2rad(obliqCorr))*sin(deg2rad(sunAppLong))))
/// [obliqCorr] - Obliq Corr calculated by the calcObliqCorr function
/// [sunAppLong] - Sun App Long calculated by the calcSunAppLong function
/// Return the sun declination
double calcSunDeclination(double obliqCorr, double sunAppLong) =>
    degrees(asin(sin(radians(obliqCorr)) * sin(radians(sunAppLong))));

/// Calculate the equation of time (minutes) based on the formula:
/// 4*rad2deg(multiFactor*sin(2*deg2rad(geomMeanLongSun))-2*eccentEarthOrbit*sin(deg2rad(geomMeanAnomSun))+4*eccentEarthOrbit*multiFactor*sin(deg2rad(geomMeanAnomSun))*cos(2*deg2rad(geomMeanLongSun))-0.5*multiFactor*multiFactor*sin(4*deg2rad(geomMeanLongSun))-1.25*eccentEarthOrbit*eccentEarthOrbit*sin(2*deg2rad(geomMeanAnomSun)))
/// [multiFactor] - The Multi Factor calculated in the calculate function
/// [geomMeanLongSun] - The Geom Mean Long Sun calculated by the calcGeomMeanLongSun function
/// [eccentEarthOrbit] - The Eccent Earth calculated by the calcEccentEarthOrbit function
/// [geomMeanAnomSun] - The Geom Mean Anom Sun calculated by the calcGeomMeanAnomSun function
/// Return the equation of time
double calcEquationOfTime(
    double multiFactor, geomMeanLongSun, eccentEarthOrbit, geomMeanAnomSun) {
  final a = multiFactor * sin(2.0 * radians(geomMeanLongSun));
  final b = 2.0 * eccentEarthOrbit * sin(radians(geomMeanAnomSun));
  final c =
      4.0 * eccentEarthOrbit * multiFactor * sin(radians(geomMeanAnomSun));
  final d = cos(2.0 * radians(geomMeanLongSun));
  final e =
      0.5 * multiFactor * multiFactor * sin(4.0 * radians(geomMeanLongSun));
  final f = 1.25 *
      eccentEarthOrbit *
      eccentEarthOrbit *
      sin(2.0 * radians(geomMeanAnomSun));
  return 4.0 * degrees(a - b + c * d - e - f);
}

/// Calculate the HaSunrise in degrees based on the formula:
/// rad2deg(acos(cos(deg2rad(90.833))/(cos(deg2rad(latitude))*cos(deg2rad(sunDeclination)))-tan(deg2rad(latitude))*tan(deg2rad(sunDeclination))))
//
/// [latitude] - The latitude defined by the user
/// [sunDeclination] - The Sun Declination calculated by the calcSunDeclination function
/// Return the HaSunrise
double calcHaSunrise(double latitude, double sunDeclination) =>
    degrees(acos(cos(radians(90.833)) /
            (cos(radians(latitude)) * cos(radians(sunDeclination))) -
        tan(radians(latitude)) * tan(radians(sunDeclination))));

/// Calculate the Solar Noon based on the formula:
/// (720 - 4 * longitude - equationOfTime + utcOffset * 60) * 60
//
/// [longitude] - The longitude is defined by the user
/// [equationOfTime] - The Equation of Time is calculated by the calcEquationOfTime function
/// [utcOffset] - The UTC offset is defined by the user
/// Return the Solar Noon
double calcSolarNoon(double longitude, double equationOfTime, int utcOffset) =>
    (720.0 - 4.0 * longitude - equationOfTime + utcOffset * 60.0) * 60.0;

double squared(double n) => n * n;

double calcMultiFactoror(double obliqCorr) =>
    squared(tan(radians(obliqCorr / 2.0)));

// Check if the latitude is valid. Range: -90 - 90
bool checkLatitude(double latitude) => !(latitude < -90.0 || latitude > 90.0);

// Check if the longitude is valid. Range: -180 - 180
bool checkLongitude(double longitude) =>
    !(longitude < -180.0 || longitude > 180.0);

// Check if the UTC offset is valid. Range: -12 - 14
bool checkUtcOffset(int utcOffset) => !(utcOffset < -12.0 || utcOffset > 14.0);

// Check if the date is valid.
bool checkDate(DateTime date) {
  final minDate = DateTime.utc(1900, 1, 1, 0, 0, 0, 0);
  final maxDate = DateTime.utc(2200, 1, 1, 0, 0, 0, 0);
  return !(date.compareTo(minDate) < 0 || date.compareTo(maxDate) > 0);
}

import 'package:sunrise_sunset_calc/sunrise_sunset_calc.dart';

main() {
  var sunriseSunset = getSunriseSunset(60.0, 60.0, 1, DateTime.now());
  print(sunriseSunset.toString());
}

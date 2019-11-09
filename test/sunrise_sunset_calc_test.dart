import 'package:sunrise_sunset_calc/sunrise_sunset_calc.dart';
import 'package:test/test.dart';

void main() {
  group('Sunrise Sunset', () {
    test('Returns correct surnire time', () {
      var expectedSunrise = DateTime.utc(2017, 3, 23, 6, 11, 41);
      var expectedSunset = DateTime.utc(2017, 3, 23, 18, 14, 34);
      var date = DateTime.utc(2017, 3, 23, 0, 0, 0);
      var ssr = getSunriseSunset(-23.545570, -46.704082, -3, date);

      expect(ssr.sunrise, equals(expectedSunrise),
          reason: 'Sunrise does not match');
      expect(ssr.sunset, equals(expectedSunset),
          reason: 'Sunset does not match');
    });
  });
}

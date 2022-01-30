import 'package:sunrise_sunset_calc/sunrise_sunset_calc.dart';
import 'package:test/test.dart';

void main() {
  group('Sunrise Sunset', () {
    final date = DateTime.utc(2017, 3, 23, 0, 0, 0);
    final expectedSunrise = DateTime.utc(2017, 3, 23, 6, 11, 41);
    final expectedSunset = DateTime.utc(2017, 3, 23, 18, 14, 34);

    test('Returns correct surnire time', () {
      final ssr = getSunriseSunset(-23.545570, -46.704082, -3, date);

      expect(ssr.sunrise, equals(expectedSunrise),
          reason: 'Sunrise does not match');
      expect(ssr.sunset, equals(expectedSunset),
          reason: 'Sunset does not match');
    });

    test('Returns correct surnire time when called as a promise', () {
      getSunriseSunsetAsync(-23.545570, -46.704082, -3, date).then((ssr) {
        expect(ssr.sunrise, equals(expectedSunrise),
            reason: 'Sunrise does not match');
        expect(ssr.sunset, equals(expectedSunset),
            reason: 'Sunset does not match');
      });
    });

    test('Returns correct surnire time when called async', () async {
      final ssr = await getSunriseSunsetAsync(-23.545570, -46.704082, -3, date);
      expect(ssr.sunrise, equals(expectedSunrise),
          reason: 'Sunrise does not match');
      expect(ssr.sunset, equals(expectedSunset),
          reason: 'Sunset does not match');
    });
  });
}

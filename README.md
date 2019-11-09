# sunrise_sunset_calc

Sunrise/Sunset calculation library ported from [sunrisesunset](https://github.com/kelvins/sunrisesunset)

## Usage

A simple usage example:

```dart
import 'package:sunrise_sunset_calc/sunrise_sunset_calc.dart';

main() {
  var sunriseSunset = getSunriseSunset(60.0, 60.0, 1, DateTime.now());
  print("Sunrise is at: ${sunriseSunset.sunrise.toString()}");
  print("Sunset is at: ${sunriseSunset.sunset.toString()}");
}
```

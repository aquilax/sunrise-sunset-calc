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

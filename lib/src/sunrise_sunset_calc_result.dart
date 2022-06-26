/// Result of SunriseSunset calculation
class SunriseSunsetResult {
  /// Constructor method
  SunriseSunsetResult(this.sunrise, this.sunset);

  /// Time of the sunrise
  DateTime sunrise;

  /// Time of the sunset
  DateTime sunset;

  @override
  String toString() =>
      'sunrise: ${sunrise.toString()}, sunset: ${sunset.toString()}';

  @override
  int get hashCode => Object.hash(sunrise, sunset);

  @override
  bool operator ==(other) =>
      other is SunriseSunsetResult &&
      sunrise == other.sunrise &&
      sunset == other.sunset;
}

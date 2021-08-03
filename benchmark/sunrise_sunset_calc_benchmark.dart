import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:sunrise_sunset_calc/sunrise_sunset_calc.dart';

// Create a new benchmark by extending BenchmarkBase
class SunriseSunsetBenchmark extends BenchmarkBase {
  const SunriseSunsetBenchmark() : super('SunriseSunset');

  static void main() {
    const SunriseSunsetBenchmark().report();
  }

  @override
  void run() {
    getSunriseSunset(50.9876, 30.1234, 3, DateTime.now());
  }
}

void main() {
  // Run TemplateBenchmark
  SunriseSunsetBenchmark.main();
}

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:sunrise_sunset_calc/sunrise_sunset_calc.dart';

class SunriseSunsetBenchmarkSync extends BenchmarkBase {
  const SunriseSunsetBenchmarkSync() : super('getSunriseSunset');

  static void main() {
    const SunriseSunsetBenchmarkSync().report();
  }

  @override
  void run() {
    getSunriseSunset(50.9876, 30.1234, 3, DateTime.now());
  }
}

class SunriseSunsetBenchmarkAsync extends AsyncBenchmarkBase {
  const SunriseSunsetBenchmarkAsync() : super('getSunriseSunsetAsync');

  static void main() async {
    await SunriseSunsetBenchmarkAsync().report();
  }

  @override
  Future<void> run() async {
    await getSunriseSunsetAsync(50.9876, 30.1234, 3, DateTime.now());
  }
}

void main() async {
  // Run TemplateBenchmark
  SunriseSunsetBenchmarkSync.main();
  SunriseSunsetBenchmarkAsync.main();
}

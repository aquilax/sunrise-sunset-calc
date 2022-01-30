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

// cherry picked from https://github.com/dart-lang/benchmark_harness/pull/44
class AsyncBenchmarkBase {
  final String name;
  final ScoreEmitter emitter;

  // Empty constructor.
  const AsyncBenchmarkBase(this.name, {this.emitter = const PrintEmitter()});

  // The benchmark code.
  // This function is not used, if both [warmup] and [exercise] are overwritten.
  Future<void> run() async {}

  // Runs a short version of the benchmark. By default invokes [run] once.
  Future<void> warmup() async {
    await run();
  }

  // Exercises the benchmark.
  Future<void> exercise() async {
    await run();
  }

  // Not measured setup code executed prior to the benchmark runs.
  Future<void> setup() async {}

  // Not measures teardown code executed after the benchark runs.
  Future<void> teardown() async {}

  // Measures the score for this benchmark by executing it repeately until
  // time minimum has been reached.
  static Future<double> measureFor(Function f, int minimumMillis) async {
    final minimumMicros = minimumMillis * 1000;
    var iter = 0;
    var watch = Stopwatch();
    watch.start();
    var elapsed = 0;
    while (elapsed < minimumMicros) {
      await f();
      elapsed = watch.elapsedMicroseconds;
      iter++;
    }
    return elapsed / iter;
  }

  // Measures the score for the benchmark and returns it.
  Future<double> measure() async {
    await setup();
    try {
      // Warmup for at least 100ms. Discard result.
      await measureFor(warmup, 100);
      // Run the benchmark for at least 2000ms.
      return await measureFor(exercise, 2000);
    } finally {
      await teardown();
    }
  }

  Future<void> report() async {
    emitter.emit(name, await measure());
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

import 'dart:math';

/// Exponential backoff with jitter: 5 s, 10 s, 20 s ... up to 15 minutes.
class BackoffPolicy {
  const new({
    this.base = const Duration(seconds: 5),
    this.max = const Duration(minutes: 15),
    this.jitter = 0.2,
  });

  final Duration base;
  final Duration max;

  /// Fraction of the delay added or removed at random (0.2 = +-20%).
  final double jitter;

  /// Delay before retry number [attempt] (the first retry is attempt 1).
  Duration delay(int attempt, [Random? random]) {
    final exp = base.inMilliseconds * pow(2, attempt < 1 ? 0 : attempt - 1);
    final capped = min(exp, max.inMilliseconds.toDouble());
    final r = random ?? Random();
    final factor = 1 + (r.nextDouble() * 2 - 1) * jitter;
    return Duration(milliseconds: (capped * factor).round());
  }
}

/// A phone clock that runs ahead must not win every conflict for ever, so
/// a stamp more than a day in the future is pulled back to a day ahead.
int clampUpdatedAt(int updatedAtMs, int nowMs) {
  const day = 24 * 60 * 60 * 1000;
  return updatedAtMs > nowMs + day ? nowMs + day : updatedAtMs;
}

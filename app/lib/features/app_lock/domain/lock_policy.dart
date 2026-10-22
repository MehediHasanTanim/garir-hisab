/// How long the app may stay in the background before it locks.
enum LockTimeout {
  immediately(Duration.zero),
  seconds30(Duration(seconds: 30)),
  minute1(Duration(minutes: 1)),
  minutes5(Duration(minutes: 5));

  new(this.duration);

  final Duration duration;
}

abstract final class LockPolicy {
  static const maxAttempts = 5;
  static const lockoutDuration = Duration(seconds: 30);

  /// Whether the app should lock when it returns to the foreground.
  static bool shouldLock({
    required DateTime? backgroundedAt,
    required DateTime now,
    required LockTimeout timeout,
  }) {
    if (backgroundedAt == null) return false;
    return now.difference(backgroundedAt) >= timeout.duration;
  }

  /// Time until another PIN attempt is allowed, or null if allowed now.
  static Duration? blockedFor({
    required int failedAttempts,
    required DateTime? lastFailureAt,
    required DateTime now,
  }) {
    if (failedAttempts < maxAttempts || lastFailureAt == null) return null;
    final remaining = lastFailureAt.add(lockoutDuration).difference(now);
    return remaining > Duration.zero ? remaining : null;
  }
}

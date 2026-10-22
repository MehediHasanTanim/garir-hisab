import 'package:flutter/material.dart';

/// Spacing scale (dp).
abstract final class Spacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;

  /// Page side gutter.
  static const double gutter = 16;
}

abstract final class Sizes {
  /// Minimum touch target (Material / spec §8).
  static const double minTap = 48;
  static const double bigButtonHeight = 56;
  static const double keypadKeyHeight = 64;
  static const double radius = 14;
}

/// Brand colours; semantic money colours live here so every screen agrees.
abstract final class AppColors {
  static const seed = Color(0xFF1B7F4B);
  static const income = Color(0xFF1B7F4B);
  static const expense = Color(0xFFB3261E);
}

import 'package:flutter/material.dart';
import 'package:vehicle_khata/app/ui/tokens.dart';

/// Light theme (dark theme comes later). Bengali glyphs currently come from
/// the platform font; bundle Noto Sans Bengali and set [fontFamily] once the
/// font asset is added (see docs/spikes/bengali-pdf.md).
abstract final class AppTheme {
  static const String? fontFamily = null;

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(seedColor: AppColors.seed);
    const shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(Sizes.radius)),
    );
    const minSize = Size(Sizes.minTap, Sizes.minTap);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: Typography.material2021().black.apply(
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      ),
      appBarTheme: const AppBarTheme(centerTitle: false),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(minimumSize: minSize, shape: shape),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(minimumSize: minSize, shape: shape),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(minimumSize: minSize),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: minSize),
      ),
      chipTheme: const ChipThemeData(
        shape: shape,
        labelPadding: EdgeInsets.symmetric(horizontal: Spacing.sm),
      ),
      navigationBarTheme: const NavigationBarThemeData(height: 72),
    );
  }
}

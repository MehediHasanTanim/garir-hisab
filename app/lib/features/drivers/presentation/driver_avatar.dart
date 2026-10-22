import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehicle_khata/app/providers/feature_providers.dart';

/// Driver photo, or the first letter of their name on a coloured circle.
class DriverAvatar extends ConsumerWidget {
  const new({
    required this.name,
    required this.photoFile,
    this.size = 48,
    super.key,
  });

  final String name;
  final String? photoFile;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final initial = name.trim().isEmpty ? '?' : name.trim().characters.first;
    final fallback = CircleAvatar(
      radius: size / 2,
      backgroundColor: scheme.tertiaryContainer,
      child: Text(
        initial,
        style: TextStyle(
          color: scheme.onTertiaryContainer,
          fontSize: size / 2.4,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
    if (photoFile == null) return fallback;
    return FutureBuilder<File?>(
      future: ref.watch(photoStoreProvider).resolve(photoFile),
      builder: (context, snap) {
        final file = snap.data;
        if (file == null) return fallback;
        return ClipRRect(
          borderRadius: BorderRadius.circular(size / 2),
          child: Image.file(
            file,
            width: size,
            height: size,
            fit: BoxFit.cover,
            cacheWidth: (size * 3).round(),
            errorBuilder: (_, _, _) => fallback,
          ),
        );
      },
    );
  }
}

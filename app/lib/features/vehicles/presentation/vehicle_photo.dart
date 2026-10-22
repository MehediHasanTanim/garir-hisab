import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehicle_khata/app/providers/feature_providers.dart';
import 'package:vehicle_khata/app/ui/vehicle_icons.dart';
import 'package:vehicle_khata/features/vehicles/domain/vehicle_enums.dart';

/// Vehicle photo (from app storage) or a type icon fallback.
class VehiclePhoto extends ConsumerWidget {
  const new({
    required this.type,
    required this.photoFile,
    this.size = 48,
    super.key,
  });

  final VehicleType type;
  final String? photoFile;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final fallback = CircleAvatar(
      radius: size / 2,
      backgroundColor: scheme.secondaryContainer,
      child: Icon(vehicleIcon(type), color: scheme.onSecondaryContainer),
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

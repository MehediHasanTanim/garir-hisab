import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:vehicle_khata/core/db/ids.dart';

/// Source of a vehicle photo.
enum PhotoSource { camera, gallery }

/// Picks an image and returns the path of a resized, compressed copy
/// (≈1280 px wide, JPEG quality 70), or null if cancelled.
abstract interface class PhotoPicker {
  Future<String?> pick(PhotoSource source);
}

class ImagePickerPhotoPicker implements PhotoPicker {
  new([ImagePicker? picker]) : _picker = picker ?? ImagePicker();

  static const maxWidth = 1280.0;
  static const quality = 70;

  final ImagePicker _picker;

  @override
  Future<String?> pick(PhotoSource source) async {
    final file = await _picker.pickImage(
      source: source == PhotoSource.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      maxWidth: maxWidth,
      imageQuality: quality,
    );
    return file?.path;
  }
}

/// Keeps photos in app storage; the database stores only the file name.
class PhotoStore {
  new(this._directory);

  /// Store under `<app support dir>/vehicle_photos`.
  factory appStorage() => PhotoStore(() async {
    final base = await getApplicationSupportDirectory();
    return Directory(p.join(base.path, 'vehicle_photos'));
  });

  final Future<Directory> Function() _directory;

  /// Copies [sourcePath] into the store and returns the stored file name.
  Future<String> save(String sourcePath) async {
    final dir = await _directory();
    await dir.create(recursive: true);
    final name = '${newId()}.jpg';
    await File(sourcePath).copy(p.join(dir.path, name));
    return name;
  }

  Future<File?> resolve(String? fileName) async {
    if (fileName == null) return null;
    final file = File(p.join((await _directory()).path, fileName));
    return file.existsSync() ? file : null;
  }

  Future<void> delete(String? fileName) async {
    final file = await resolve(fileName);
    if (file != null) await file.delete();
  }
}

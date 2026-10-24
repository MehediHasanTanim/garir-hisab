import 'dart:typed_data';

import 'package:vehicle_khata/core/share/file_sharer.dart';

class SharedFile {
  new(this.fileName, this.mimeType, this.bytes, this.text);

  final String fileName;
  final String mimeType;
  final Uint8List bytes;
  final String? text;
}

class FakeFileSharer implements FileSharer {
  final shared = <SharedFile>[];

  @override
  Future<void> shareBytes({
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
    String? text,
  }) async => shared.add(SharedFile(fileName, mimeType, bytes, text));
}

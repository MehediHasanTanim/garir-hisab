import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Hands a file to the system share sheet (WhatsApp, Drive, email...).
abstract interface class FileSharer {
  Future<void> shareBytes({
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
    String? text,
  });
}

class SystemFileSharer implements FileSharer {
  const new();

  @override
  Future<void> shareBytes({
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
    String? text,
  }) async {
    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, fileName));
    await file.writeAsBytes(bytes, flush: true);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: mimeType)],
        text: text,
      ),
    );
  }
}

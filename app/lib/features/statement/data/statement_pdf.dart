import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Puts a picture of the statement on A4 pages (as many as its height needs).
///
/// The statement is drawn by Flutter and embedded as an image, because the
/// `pdf` package cannot shape Bangla conjuncts; Flutter's text engine can.
Future<Uint8List> imageToPdf({
  required Uint8List png,
  required int widthPx,
  required int heightPx,
  String? title,
}) {
  const format = PdfPageFormat.a4;
  final image = pw.MemoryImage(png);
  final totalHeight = heightPx * format.width / widthPx;
  final pages = (totalHeight / format.height).ceil().clamp(1, 50);
  final doc = pw.Document(title: title, creator: 'Vehicle Khata');
  for (var i = 0; i < pages; i++) {
    doc.addPage(
      pw.Page(
        pageFormat: format,
        margin: pw.EdgeInsets.zero,
        build: (_) => pw.SizedBox(
          width: format.width,
          height: format.height,
          child: pw.ClipRect(
            child: pw.Stack(
              children: [
                pw.Positioned(
                  left: 0,
                  top: -i * format.height,
                  child: pw.Image(
                    image,
                    width: format.width,
                    height: totalHeight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  return doc.save();
}

// S0-T5 spike: Bengali PDF with an embedded Noto Sans Bengali font.
// Drop NotoSansBengali-Regular.ttf into assets/fonts/ (see docs/spikes).
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Text samples that stress Bengali shaping: conjuncts (যুক্তাক্ষর),
/// reph, vowel signs that reorder, and Bangla numerals.
const bengaliSamples = <String>[
  'গাড়ির হিসাব খাতা',
  'আজকের আয়: ৳ ২,৮০০',
  'যুক্তাক্ষর: ক্ষ ত্র জ্ঞ স্ক্র ন্দ্র',
  'কর্ম র‍্যাব কিংবা কোন্',
  'মোট লাভ ৳ ১,২৩,৪৫৬',
];

Future<Uint8List> buildBengaliPdf(ByteData fontData) async {
  final font = pw.Font.ttf(fontData);
  final doc = pw.Document();
  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      theme: pw.ThemeData.withFont(base: font, bold: font),
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          for (final s in bengaliSamples)
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 12),
              child: pw.Text(s, style: const pw.TextStyle(fontSize: 22)),
            ),
        ],
      ),
    ),
  );
  return doc.save();
}

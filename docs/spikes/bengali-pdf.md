# Spike S0-T5: Bengali PDF

**Code:** `app/lib/spikes/bengali_pdf.dart` (sample strings with conjuncts and Bangla numerals)

## Status: not run
The Noto Sans Bengali font file is not in the repo (`app/assets/fonts/` is empty;
download it from Google Fonts, SIL OFL licence) and no device was available.

## Known risk to verify first
The Dart `pdf` package embeds TrueType glyphs but historically does **not**
perform complex-script shaping (conjunct formation, vowel-sign reordering) for
Bengali. Expect broken conjuncts unless verified otherwise.

## Steps
1. Add `NotoSansBengali-Regular.ttf` to `app/assets/fonts/` and register it under `flutter: assets`.
2. Call `buildBengaliPdf` and inspect output on device and when shared to WhatsApp.
3. If shaping is broken, fall back to rendering report pages as images using Flutter's text engine (which shapes correctly) and wrapping them in a PDF.

## Decision
**Pending.** Fallback (3) is expected to be needed; plan Sprint 6 accordingly.

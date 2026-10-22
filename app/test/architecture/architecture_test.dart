import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Import-lint (S1-T1): domain code must be pure Dart.
const _forbiddenInDomain = [
  'package:flutter/',
  'package:flutter_',
  'package:drift/',
  'dart:ui',
];

Iterable<File> _dartFiles(String root) => Directory(root).existsSync()
    ? Directory(root)
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart') && !f.path.endsWith('.g.dart'))
    : const [];

bool _isDomain(String path) =>
    path.contains('/domain/') ||
    path.startsWith('lib/core/money/') ||
    path == 'lib/core/settings/app_settings.dart';

void main() {
  test('domain and core/money are free of Flutter and Drift imports', () {
    final files = _dartFiles('lib').where((f) => _isDomain(f.path)).toList();
    expect(files, isNotEmpty, reason: 'rule must cover real files');

    final violations = <String>[];
    for (final f in files) {
      for (final line in f.readAsLinesSync()) {
        if (!line.startsWith('import ')) continue;
        if (_forbiddenInDomain.any(line.contains)) {
          violations.add('${f.path}: $line');
        }
      }
    }
    expect(violations, isEmpty);
  });

  test('no hard-coded user-facing strings in widgets', () {
    // Text('...') whose first string literal contains letters outside of
    // ${...} / $name interpolations. All UI text must come from
    // AppLocalizations; formatting glue like '$a: $b' is fine.
    final literalText = RegExp(
      r"""Text\(\s*(?:const\s+)?(['"])((?:(?!\1)[\s\S])*)\1""",
    );
    final interpolation = RegExp(r'\$\{[^}]*\}|\$[A-Za-z_]\w*');
    final violations = <String>[];
    for (final f in _dartFiles('lib')) {
      if (f.path.startsWith('lib/spikes/') || f.path.startsWith('lib/l10n/')) {
        continue;
      }
      // Drop ${...} bodies first: they may contain quotes of their own.
      final source = f.readAsStringSync().replaceAll(
        RegExp(r'\$\{[^}]*\}'),
        r'$x',
      );
      for (final m in literalText.allMatches(source)) {
        final text = m
            .group(2)!
            .replaceAll(interpolation, '')
            .replaceAll(RegExp(r'\\.'), '');
        if (RegExp('[A-Za-z]').hasMatch(text)) {
          violations.add('${f.path}: ${m.group(0)}');
        }
      }
    }
    expect(violations, isEmpty);
  });

  test('every English string has a Bangla translation', () {
    final en = RegExp('^  "([A-Za-z0-9_]+)":', multiLine: true);
    Set<String> keys(String path) => en
        .allMatches(File(path).readAsStringSync())
        .map((m) => m.group(1)!)
        .where((k) => !k.startsWith('@'))
        .toSet();
    expect(keys('lib/l10n/app_bn.arb'), keys('lib/l10n/app_en.arb'));
  });
}

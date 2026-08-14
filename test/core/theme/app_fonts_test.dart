import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('registered fonts', () {
    test('FontManifest contains Inter and NotoSansArabic with needed weights',
        () async {
      final manifestJson = await rootBundle.loadString('FontManifest.json');
      final manifest = jsonDecode(manifestJson) as List<dynamic>;

      final families = <String, Set<int>>{};
      for (final entry in manifest.cast<Map<String, dynamic>>()) {
        final family = entry['family'] as String;
        final fonts = (entry['fonts'] as List<dynamic>)
            .cast<Map<String, dynamic>>();
        families.putIfAbsent(family, () => {}).addAll(
              fonts.map((f) => (f['weight'] as num?)?.toInt() ?? 400),
            );
      }

      // Inter: full UI scale used by AppTypography (400/500/600/700/800)
      expect(families.containsKey('Inter'), isTrue);
      expect(families['Inter'], containsAll(<int>{400, 500, 600, 700, 800}));

      // NotoSansArabic: Arabic fallback (400/500/600/700)
      expect(families.containsKey('NotoSansArabic'), isTrue);
      expect(families['NotoSansArabic'], containsAll(<int>{400, 500, 600, 700}));
    });

    test('all declared font asset files load successfully', () async {
      const paths = [
        'assets/fonts/Inter-Regular.ttf',
        'assets/fonts/Inter-Medium.ttf',
        'assets/fonts/Inter-SemiBold.ttf',
        'assets/fonts/Inter-Bold.ttf',
        'assets/fonts/Inter-ExtraBold.ttf',
        'assets/fonts/NotoSansArabic-Regular.ttf',
        'assets/fonts/NotoSansArabic-Medium.ttf',
        'assets/fonts/NotoSansArabic-SemiBold.ttf',
        'assets/fonts/NotoSansArabic-Bold.ttf',
      ];

      for (final path in paths) {
        final data = await rootBundle.load(path);
        expect(data.lengthInBytes, greaterThan(0), reason: '$path is empty');
      }
    });
  });
}

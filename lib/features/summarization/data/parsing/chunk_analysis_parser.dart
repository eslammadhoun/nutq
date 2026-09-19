import 'package:nutq/features/summarization/domain/entities/chunk_analysis.dart';

/// Parses the MAIN / POINTS / FACTS / IMPORTANT_TERMS response format.
///
/// Tolerant by design: headings may be lowercase, bold, prefixed with `#`,
/// missing a colon, or missing entirely; bullets may use any marker. If no
/// heading is recognised at all, the whole response becomes `main`
/// (`usedFallback`). It never throws.
class ChunkAnalysisParser {
  const ChunkAnalysisParser();

  static final _heading = RegExp(
    r'^[\s#>*_`-]*(MAIN|POINTS|FACTS|IMPORTANT[\s_-]*TERMS)[\s*_`]*[:：]?[\s*_`]*(.*)$',
    caseSensitive: false,
  );
  static final _bullet = RegExp(r'^\s*(?:[-•*–—]|\d+[.)])\s+');
  static final _placeholder = RegExp(r'^[.…\s]*$');

  ChunkAnalysis parse(int chunkId, String response) {
    final text = response.trim();
    if (text.isEmpty) return ChunkAnalysis(chunkId: chunkId);

    final sections = <String, List<String>>{};
    String? current;
    var sawHeading = false;

    for (final line in text.split('\n')) {
      final m = _heading.firstMatch(line);
      if (m != null) {
        sawHeading = true;
        current = _canonical(m.group(1)!);
        sections.putIfAbsent(current, () => []);
        final rest = m.group(2)!.trim();
        if (rest.isNotEmpty) sections[current]!.add(rest);
        continue;
      }
      if (current != null && line.trim().isNotEmpty) {
        sections[current]!.add(line.trim());
      }
    }

    if (!sawHeading) {
      return ChunkAnalysis(chunkId: chunkId, main: text, usedFallback: true);
    }

    return ChunkAnalysis(
      chunkId: chunkId,
      main: _items(sections['MAIN']).join(' '),
      points: _items(sections['POINTS']),
      facts: _items(sections['FACTS']),
      importantTerms: _items(sections['TERMS']),
    );
  }

  String _canonical(String heading) {
    final h = heading.toUpperCase();
    return h.startsWith('IMPORTANT') ? 'TERMS' : h;
  }

  List<String> _items(List<String>? lines) {
    if (lines == null) return const [];
    final out = <String>[];
    for (final raw in lines) {
      final stripped = raw.replaceFirst(_bullet, '').trim();
      if (stripped.isEmpty || _placeholder.hasMatch(stripped)) continue;
      out.add(stripped);
    }
    return out;
  }
}

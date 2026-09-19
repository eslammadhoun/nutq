/// Counts model tokens for budgeting chunks and prompts.
abstract class TokenCounter {
  Future<int> count(String text);
}

/// Character-based estimate for tests and as a fallback when the real
/// tokenizer is unavailable. Deliberately conservative (over-counts), so
/// chunks err on the small side rather than overflowing the context window.
///
/// Production chunking should use the model's tokenizer (see
/// `GemmaTokenCounter` in the data layer).
class ApproximateTokenCounter implements TokenCounter {
  const ApproximateTokenCounter();

  static final _arabic = RegExp(r'[؀-ۿ]');

  @override
  Future<int> count(String text) async => estimate(text);

  int estimate(String text) {
    var tokens = 0;
    for (final word in text.split(RegExp(r'\s+'))) {
      if (word.isEmpty) continue;
      final divisor = _arabic.hasMatch(word) ? 3 : 4;
      tokens += (word.length / divisor).ceil() + 1;
    }
    return tokens;
  }
}

/// Memoizes another counter (chunking asks about the same sentences often).
class CachingTokenCounter implements TokenCounter {
  CachingTokenCounter(this._inner, {this.maxEntries = 4096});

  final TokenCounter _inner;
  final int maxEntries;
  final Map<String, int> _cache = {};

  @override
  Future<int> count(String text) async {
    final cached = _cache[text];
    if (cached != null) return cached;
    final value = await _inner.count(text);
    if (_cache.length >= maxEntries) _cache.remove(_cache.keys.first);
    _cache[text] = value;
    return value;
  }
}

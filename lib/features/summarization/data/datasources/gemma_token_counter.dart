import 'package:nutq/features/summarization/data/datasources/gemma_local_datasource.dart';
import 'package:nutq/features/summarization/domain/text/token_counter.dart';

/// Counts tokens with the model's own tokenizer, falling back to the
/// approximate counter if the tokenizer is unavailable.
class GemmaTokenCounter implements TokenCounter {
  GemmaTokenCounter(this._dataSource, {this._fallback = const ApproximateTokenCounter()});

  final GemmaLocalDataSource _dataSource;
  final TokenCounter _fallback;

  @override
  Future<int> count(String text) async {
    try {
      return await _dataSource.countTokens(text);
    } catch (_) {
      return _fallback.count(text);
    }
  }
}

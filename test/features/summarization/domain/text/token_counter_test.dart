import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/features/summarization/domain/text/token_counter.dart';

class _CountingCounter implements TokenCounter {
  int calls = 0;

  @override
  Future<int> count(String text) async {
    calls++;
    return text.length;
  }
}

void main() {
  test('approximate counter is monotonic and non-zero for text', () async {
    const counter = ApproximateTokenCounter();
    final short = await counter.count('مرحبا بكم');
    final long = await counter.count('مرحبا بكم في هذا الدرس الطويل عن الذكاء الاصطناعي');
    expect(short, greaterThan(0));
    expect(long, greaterThan(short));
    expect(await counter.count(''), 0);
  });

  test('caching counter memoizes and bounds its cache', () async {
    final inner = _CountingCounter();
    final counter = CachingTokenCounter(inner, maxEntries: 2);
    expect(await counter.count('abc'), 3);
    expect(await counter.count('abc'), 3);
    expect(inner.calls, 1);

    await counter.count('d');
    await counter.count('ee'); // evicts 'abc'
    await counter.count('abc');
    expect(inner.calls, 4);
  });
}

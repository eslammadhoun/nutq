import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/features/jobs/presentation/cubit/new_job_cubit.dart';
import 'package:nutq/features/jobs/presentation/cubit/new_job_state.dart';

void main() {
  test('only a non-empty text source can be submitted', () {
    final cubit = NewJobCubit();
    expect(cubit.state.canSubmit, isFalse);

    cubit.setText('   ');
    expect(cubit.state.canSubmit, isFalse);

    cubit.setText('نص للتلخيص');
    expect(cubit.state.canSubmit, isTrue);

    cubit.changeSourceType(NewJobSourceType.youtube.index);
    cubit.setSourceUrl('https://www.youtube.com/watch?v=abcdefghijk');
    expect(cubit.state.isSourceSupported, isFalse);
    expect(cubit.state.canSubmit, isFalse);
  });

  blocTest<NewJobCubit, NewJobState>(
    'submit with valid text emits success and keeps the text',
    build: NewJobCubit.new,
    act: (c) {
      c.setText('نص للتلخيص');
      c.submit();
    },
    verify: (c) {
      expect(c.state.status, NewJobStatus.success);
      expect(c.state.text, 'نص للتلخيص');
    },
  );

  blocTest<NewJobCubit, NewJobState>(
    'submit with nothing to submit does nothing',
    build: NewJobCubit.new,
    act: (c) => c.submit(),
    expect: () => <NewJobState>[],
  );
}

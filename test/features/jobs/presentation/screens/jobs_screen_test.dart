import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nutq/core/network/api_result.dart';
import 'package:nutq/features/jobs/data/models/job_models.dart';
import 'package:nutq/features/jobs/domain/repositories/jobs_repository.dart';
import 'package:nutq/features/jobs/presentation/cubit/jobs_cubit.dart';
import 'package:nutq/features/jobs/presentation/screens/jobs_screen.dart';

class MockJobsRepository extends Mock implements JobsRepository {}

void main() {
  late MockJobsRepository repository;

  setUp(() {
    repository = MockJobsRepository();
  });

  Widget wrap() => MaterialApp(
    home: BlocProvider(
      create: (_) => JobsCubit(repository),
      child: const JobsScreen(),
    ),
  );

  JobModel buildJob({String id = '1'}) => JobModel(
    id: id,
    status: 'pending',
    sourceType: 'text',
    language: 'ar',
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );

  testWidgets('shows a loading indicator while the first page loads', (
    tester,
  ) async {
    when(() => repository.getJobs()).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      return const ApiResult.success(
        JobListResponseModel(items: [], nextCursor: null),
      );
    });

    await tester.pumpWidget(wrap());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('renders a card per job once loaded', (tester) async {
    when(() => repository.getJobs()).thenAnswer(
      (_) async => ApiResult.success(
        JobListResponseModel(
          items: [buildJob(id: '1'), buildJob(id: '2')],
          nextCursor: null,
        ),
      ),
    );

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.text('Text'), findsNWidgets(2));
    expect(find.text('Pending'), findsNWidgets(2));
  });

  testWidgets('shows the empty state when there are no jobs', (tester) async {
    when(() => repository.getJobs()).thenAnswer(
      (_) async =>
          const ApiResult.success(JobListResponseModel(items: [], nextCursor: null)),
    );

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.text('No jobs yet. Tap + to submit one.'), findsOneWidget);
  });

  testWidgets('shows an error with a retry button on failure', (
    tester,
  ) async {
    when(
      () => repository.getJobs(),
    ).thenAnswer((_) async => const ApiResult.failure('Server error'));

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.text('Server error'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Retry'), findsOneWidget);
  });

  testWidgets('opens the new job sheet from the FAB', (tester) async {
    when(() => repository.getJobs()).thenAnswer(
      (_) async =>
          const ApiResult.success(JobListResponseModel(items: [], nextCursor: null)),
    );

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('New text job'), findsOneWidget);
  });
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutq/features/jobs/presentation/cubit/jobs_state.dart';
import 'package:nutq/features/jobs/presentation/models/job.dart';

// TODO(jobs-api): replace mock seed data with a real JobsRepository once the
// jobs API is wired up.
class JobsCubit extends Cubit<JobsState> {
  JobsCubit() : super(JobsState(allJobs: _mockJobs));

  static final List<Job> _mockJobs = [
    const Job(
      id: '1',
      title: 'تفريغ خطاب الرئيس في مؤتمر القمة العربية الأخير',
      sourceType: JobSourceType.upload,
      status: JobStatus.done,
      timestampLabel: 'Today, 2:30 PM',
      language: 'Arabic',
    ),
    const Job(
      id: '2',
      title: 'محاضرة في الذكاء الاصطناعي واللغة العربية',
      sourceType: JobSourceType.youtube,
      status: JobStatus.processing,
      timestampLabel: 'Today, 1:15 PM',
      language: 'Arabic',
    ),
    const Job(
      id: '3',
      title: 'برنامج إذاعي عن تطور اللغة العربية المعاصرة',
      sourceType: JobSourceType.url,
      status: JobStatus.done,
      timestampLabel: 'Yesterday',
      language: 'Arabic',
    ),
  ];

  void selectFilter(JobStatus? status) {
    if (status == null) {
      emit(state.copyWith(clearFilter: true));
    } else {
      emit(state.copyWith(selectedFilter: status));
    }
  }

  void search(String query) {
    emit(state.copyWith(searchQuery: query));
  }
}

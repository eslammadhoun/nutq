import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/core/widgets/global_button.dart';
import 'package:nutq/features/jobs/presentation/cubit/jobs_cubit.dart';
import 'package:nutq/features/jobs/presentation/cubit/jobs_state.dart';
import 'package:nutq/features/jobs/presentation/widgets/job_card.dart';

class JobsList extends StatefulWidget {
  const JobsList({super.key});

  @override
  State<JobsList> createState() => _JobsListState();
}

class _JobsListState extends State<JobsList> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<JobsCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JobsCubit, JobsState>(
      builder: (context, state) {
        if (state.status == JobsStatus.loading && state.allJobs.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == JobsStatus.failure && state.allJobs.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    state.errorMessage ?? 'Something went wrong',
                    textAlign: TextAlign.center,
                    style: context.typography.bodySmall.copyWith(
                      color: context.appColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  GlobalButton(
                    isFilled: false,
                    text: 'Retry',
                    onTap: () => context.read<JobsCubit>().fetchJobs(),
                  ),
                ],
              ),
            ),
          );
        }

        final jobs = state.filteredJobs;

        if (jobs.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => context.read<JobsCubit>().refresh(),
            child: ListView(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 64.h),
                  child: Center(
                    child: Text(
                      'No transcriptions found',
                      style: context.typography.bodySmall.copyWith(
                        color: context.appColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => context.read<JobsCubit>().refresh(),
          child: ListView.separated(
            controller: _scrollController,
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            itemCount: jobs.length + (state.isLoadingMore ? 1 : 0),
            separatorBuilder: (_, _) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              if (index >= jobs.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return JobCard(job: jobs[index]);
            },
          ),
        );
      },
    );
  }
}

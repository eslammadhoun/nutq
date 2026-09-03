import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nutq/core/extensions/error_l10n_extension.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/core/widgets/global_button.dart';
import 'package:nutq/features/jobs/presentation/cubit/jobs_cubit.dart';
import 'package:nutq/features/jobs/presentation/cubit/jobs_state.dart';
import 'package:nutq/features/jobs/presentation/models/job.dart';
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
    return BlocListener<JobsCubit, JobsState>(
      listenWhen: (previous, current) =>
          current.deleteError != null &&
          previous.deleteErrorToken != current.deleteErrorToken,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(context.l10n.jobsErrorMessage(state.deleteError!)),
              backgroundColor: context.appColors.statusFailed,
            ),
          );
      },
      child: BlocBuilder<JobsCubit, JobsState>(
        builder: (context, state) {
          if (state.status == JobsStatus.loading && state.allJobs.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == JobsStatus.failure && state.allJobs.isEmpty) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 32.w),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            state.lastError != null
                                ? context.l10n.jobsErrorMessage(state.lastError!)
                                : context.l10n.somethingWentWrong,
                            textAlign: TextAlign.center,
                            style: context.typography.bodySmall.copyWith(
                              color: context.appColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          GlobalButton(
                            isFilled: false,
                            text: context.l10n.retry,
                            onTap: () => context.read<JobsCubit>().fetchJobs(),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }

          final jobs = state.filteredJobs;

          if (jobs.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => context.read<JobsCubit>().refresh(),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Center(child: noJobsWidget()),
                      ),
                    ],
                  );
                },
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<JobsCubit>().refresh(),
            child: ListView.separated(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 16.h),
              itemCount: jobs.length + (state.isLoadingMore ? 1 : 0),
              separatorBuilder: (_, _) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final Job job = jobs[index];
                if (index >= jobs.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return Dismissible(
                  key: Key(job.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (dir) =>
                      context.read<JobsCubit>().deleteJob(job.id),
                  background: Container(
                    alignment: AlignmentDirectional.centerEnd,
                    padding: EdgeInsetsDirectional.only(end: 24.w),
                    decoration: BoxDecoration(
                      color: context.appColors.statusFailedBg,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.delete_rounded,
                      color: context.appColors.statusFailed,
                    ),
                  ),
                  child: JobCard(job: job),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget noJobsWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 64.w,
          height: 64.h,
          decoration: BoxDecoration(
            color: context.appColors.primary.withValues(
              alpha: context.isDark ? 0.14 : 0.08,
            ),
            border: BoxBorder.all(
              color: context.appColors.primary.withValues(alpha: 0.18),
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: SvgPicture.asset(
              'assets/svgs/nutq-icon.svg',
              colorFilter: ColorFilter.mode(
                context.appColors.primary.withValues(alpha: 0.50),
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        SizedBox(height: 18.h),
        Text(
          context.l10n.jobsEmptyTitle,
          style: context.typography.heading4.copyWith(
            color: context.appColors.textPrimary,
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          context.l10n.jobsEmptySubtitle,
          style: context.typography.bodyMedium.copyWith(
            color: context.appColors.textSecondary,
            fontWeight: FontWeight.w100,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

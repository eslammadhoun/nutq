import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nutq/core/extensions/error_l10n_extension.dart';
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
          );
        }

        final jobs = state.filteredJobs;

        if (jobs.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => context.read<JobsCubit>().refresh(),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return ListView(
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

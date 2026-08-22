import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/features/jobs/presentation/cubit/jobs_cubit.dart';
import 'package:nutq/features/jobs/presentation/cubit/jobs_state.dart';
import 'package:nutq/features/jobs/presentation/models/job.dart';

class JobsFilterChips extends StatelessWidget {
  const JobsFilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JobsCubit, JobsState>(
      buildWhen: (previous, current) =>
          previous.selectedFilter != current.selectedFilter,
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Row(
            children: [
              _FilterChip(
                label: 'All',
                isSelected: state.selectedFilter == null,
                onTap: () => context.read<JobsCubit>().selectFilter(null),
              ),
              SizedBox(width: 8.w),
              _FilterChip(
                label: 'Done',
                isSelected: state.selectedFilter == JobStatus.done,
                onTap: () =>
                    context.read<JobsCubit>().selectFilter(JobStatus.done),
              ),
              SizedBox(width: 8.w),
              _FilterChip(
                label: 'Processing',
                isSelected: state.selectedFilter == JobStatus.processing,
                onTap: () => context
                    .read<JobsCubit>()
                    .selectFilter(JobStatus.processing),
              ),
              SizedBox(width: 8.w),
              _FilterChip(
                label: 'Failed',
                isSelected: state.selectedFilter == JobStatus.failed,
                onTap: () =>
                    context.read<JobsCubit>().selectFilter(JobStatus.failed),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        height: 28.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? colors.primary.withValues(alpha: 0.12) : null,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected
                ? colors.primary.withValues(alpha: 0.25)
                : colors.borderDefault,
          ),
        ),
        child: Text(
          label,
          style:
              (isSelected
                      ? context.typography.labelXS
                      : context.typography.bodySmall)
                  .copyWith(
                    color: isSelected ? colors.primary : colors.textSecondary,
                  ),
        ),
      ),
    );
  }
}

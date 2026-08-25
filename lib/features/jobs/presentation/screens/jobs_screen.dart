import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/core/theme/app_colors.dart';
import 'package:nutq/core/widgets/global_text_field.dart';
import 'package:nutq/features/jobs/presentation/cubit/jobs_cubit.dart';
import 'package:nutq/features/jobs/presentation/widgets/jobs_filter_chips.dart';
import 'package:nutq/features/jobs/presentation/widgets/jobs_list.dart';
import 'package:nutq/features/jobs/presentation/widgets/new_job_widgets/new_job_sheet.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<JobsCubit>().fetchJobs();
  }

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.appColors;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 25.w),
          child: Column(
            children: [
              SizedBox(height: 10.h),
              jobsScreenHeader(colors: colors),
              SizedBox(height: 18.h),
              GlobalTextField(
                hintText: context.l10n.jobsSearchHint,
                textInputType: TextInputType.text,
                prefixWidget: Icon(
                  Icons.search_rounded,
                  size: 20.sp,
                  color: context.appColors.textMuted,
                ),
                onChanged: (value) => context.read<JobsCubit>().search(value),
              ),
              SizedBox(height: 12.h),
              const JobsFilterChips(),
              const Expanded(child: JobsList()),
            ],
          ),
        ),
      ),
      floatingActionButton: newJobFloatingButton(colors: colors),
    );
  }

  Widget jobsScreenHeader({required AppColors colors}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          context.l10n.jobsHistoryTitle,
          style: context.typography.headingLarge,
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.surface,
                border: BoxBorder.all(color: colors.borderDefault),
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                size: 18.sp,
                color: colors.textPrimary,
              ),
            ),
            Positioned(
              right: 6.w,
              top: -2,
              child: Center(
                child: Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: colors.statusFailed,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.borderDefault, width: 1.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget newJobFloatingButton({required AppColors colors}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withValues(alpha: 0.45),
              blurRadius: 16,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: FloatingActionButton(
          elevation: 0,
          backgroundColor: colors.primary,
          onPressed: () => _openNewJobSheet(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(Icons.add_rounded, color: colors.textInverse),
        ),
      ),
    );
  }

  void _openNewJobSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => const NewJobSheet(),
    );
  }
}

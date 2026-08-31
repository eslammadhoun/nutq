import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nutq/core/di/dependency_injection.dart';
import 'package:nutq/core/extensions/error_l10n_extension.dart';
import 'package:nutq/core/extensions/navigation_extension.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/features/jobs/presentation/cubit/new_job_cubit.dart';
import 'package:nutq/features/jobs/presentation/cubit/new_job_state.dart';
import 'package:nutq/features/jobs/presentation/widgets/new_job_widgets/idempotency_row.dart';
import 'package:nutq/features/jobs/presentation/widgets/new_job_widgets/language_row.dart';
import 'package:nutq/features/jobs/presentation/widgets/new_job_widgets/source_input_section.dart';
import 'package:nutq/features/jobs/presentation/widgets/new_job_widgets/source_type_selector.dart';
import 'package:nutq/features/jobs/presentation/widgets/new_job_widgets/submit_job_button.dart';

class NewJobSheet extends StatelessWidget {
  const NewJobSheet({super.key, this.onSubmitted});

  /// Called after a job was submitted successfully (upload + confirm done).
  final VoidCallback? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return BlocProvider<NewJobCubit>(
      create: (_) => sl<NewJobCubit>(),
      child: BlocListener<NewJobCubit, NewJobState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          switch (state.status) {
            case NewJobStatus.success:
              onSubmitted?.call();
            case NewJobStatus.failure when state.lastError != null:
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(
                      context.l10n.jobsErrorMessage(state.lastError!),
                    ),
                    backgroundColor: colors.statusFailed,
                  ),
                );
            case _:
              break;
          }
        },
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.92,
            ),
            decoration: BoxDecoration(
              color: colors.navBarBg,
              borderRadius: BorderRadiusDirectional.only(
                topStart: Radius.circular(24.r),
                topEnd: Radius.circular(24.r),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 12.h),
                    dragHandle(context),
                    SizedBox(height: 16.h),
                    headerRow(context),
                    SizedBox(height: 20.h),
                    const SourceTypeSelector(),
                    SizedBox(height: 12.h),
                    const LanguageRow(),
                    SizedBox(height: 8.h),
                    const IdempotencyRow(),
                    SizedBox(height: 16.h),
                    Flexible(
                      child: SingleChildScrollView(
                        child: const SourceInputSection(),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0.w, 16.h, 0.w, 12.h),
                      child: const SubmitJobButton(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget dragHandle(BuildContext context) {
    return Container(
      width: 36.w,
      height: 4.h,
      decoration: BoxDecoration(
        color: context.appColors.textMuted.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget headerRow(BuildContext context) {
    final colors = context.appColors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          context.l10n.newJobTitle,
          style: context.typography.heading3.copyWith(
            color: colors.textPrimary,
          ),
        ),
        InkWell(
          onTap: () => context.pop(),
          child: Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.card,
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/svgs/close.svg',
                width: 12.w,
                colorFilter: ColorFilter.mode(
                  colors.textSecondary,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/features/jobs/presentation/cubit/job_detail_cubit.dart';
import 'package:nutq/features/jobs/presentation/cubit/job_detail_state.dart';
import 'package:share_plus/share_plus.dart';

class JobDetailActionBar extends StatelessWidget {
  const JobDetailActionBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return BlocBuilder<JobDetailCubit, JobDetailState>(
      buildWhen: (previous, current) =>
          previous.job != current.job ||
          previous.streamingSummary != current.streamingSummary ||
          previous.isCancelling != current.isCancelling,
      builder: (context, state) {
        final job = state.job;
        if (job == null) return const SizedBox.shrink();

        final canCancel = job.status.isActive;
        // While the summary streams in, share/copy what has arrived; once the
        // job settles the stored summary is the same text.
        final summaryText = state.streamingSummary?.isNotEmpty ?? false
            ? state.streamingSummary
            : job.summary?.summaryText;
        final hasSummaryText = summaryText != null && summaryText.isNotEmpty;

        return Container(
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border(top: BorderSide(color: colors.borderDefault)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(16.w, 13.h, 16.w, 14.h),
              child: canCancel
                  ? _ActionButton(
                      icon: Icons.cancel_outlined,
                      label: state.isCancelling
                          ? context.l10n.jobDetailCancelling
                          : context.l10n.jobDetailCancelJob,
                      background: colors.statusFailed,
                      foreground: colors.textInverse,
                      onTap: state.isCancelling
                          ? null
                          : () => context.read<JobDetailCubit>().cancelJob(),
                    )
                  : Row(
                      // Figma allots 163px to Share and 180px to Copy Text
                      // (out of a 343px row) — not an even split.
                      children: [
                        Expanded(
                          flex: 163,
                          child: _ActionButton(
                            icon: Icons.north_east_rounded,
                            label: context.l10n.jobDetailShare,
                            background: colors.borderDefault,
                            foreground: colors.textPrimary,
                            onTap: hasSummaryText ? () => _shareSummary(summaryText) : null,
                          ),
                        ),
                        SizedBox(width: 15.w),
                        Expanded(
                          flex: 180,
                          child: _ActionButton(
                            label: context.l10n.jobDetailCopyText,
                            background: colors.navIndicator,
                            foreground: colors.textInverse,
                            onTap: hasSummaryText ? () => _copySummary(context, summaryText) : null,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  void _copySummary(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(context.l10n.jobDetailCopyText)));
  }

  void _shareSummary(String text) {
    unawaited(SharePlus.instance.share(ShareParams(text: text)));
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
    this.icon,
  });

  final String label;
  final Color background;
  final Color foreground;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return InkWell(
      borderRadius: BorderRadius.circular(10.r),
      onTap: onTap,
      child: Container(
        height: 44.h,
        decoration: BoxDecoration(
          color: disabled ? background.withValues(alpha: 0.5) : background,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14.sp, color: foreground),
              SizedBox(width: 6.w),
            ],
            Text(
              label,
              style: context.typography.labelSmall.copyWith(color: foreground),
            ),
          ],
        ),
      ),
    );
  }
}

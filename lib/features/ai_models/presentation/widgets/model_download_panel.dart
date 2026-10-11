import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/extensions/error_l10n_extension.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/core/widgets/global_button.dart';
import 'package:nutq/features/ai_models/presentation/cubit/model_download_cubit.dart';
import 'package:nutq/features/jobs/presentation/utils/job_display_format.dart';

/// Size, progress and the one button that downloads, pauses, resumes or
/// retries the packs of the [ModelDownloadCubit] above it. [onDone] is the
/// button once everything is ready.
class ModelDownloadPanel extends StatelessWidget {
  const ModelDownloadPanel({super.key, required this.title, required this.onDone});

  final String title;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;
    return BlocBuilder<ModelDownloadCubit, ModelDownloadState>(
      builder: (context, state) {
        final cubit = context.read<ModelDownloadCubit>();
        final error = state.error;
        final started = state.receivedBytes > 0;
        final (label, action) = switch (state) {
          _ when state.isReady => (l10n.modelsContinue, onDone),
          _ when state.isDownloading => (l10n.modelsPause, cubit.pause),
          _ when error != null => (l10n.modelsRetry, cubit.download),
          _ when started => (l10n.modelsResume, cubit.download),
          _ => (l10n.modelsDownload, cubit.download),
        };
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: context.typography.heading3, textAlign: TextAlign.center),
            SizedBox(height: 12.h),
            Text(
              state.isReady ? l10n.modelsReady : l10n.modelsBody(formatBytes(state.totalBytes)),
              style: context.typography.bodySmall.copyWith(color: colors.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: LinearProgressIndicator(
                value: state.progress,
                minHeight: 8.h,
                color: state.isReady ? colors.statusDone : colors.primary,
                backgroundColor: colors.borderSubtle,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.modelsProgress(
                      formatBytes(state.receivedBytes),
                      formatBytes(state.totalBytes),
                    ),
                    style: context.typography.caption.copyWith(color: colors.textSecondary),
                  ),
                ),
                if (!state.isReady)
                  Text(
                    l10n.modelsWifi,
                    style: context.typography.caption.copyWith(color: colors.textSecondary),
                  ),
              ],
            ),
            if (error != null) ...[
              SizedBox(height: 12.h),
              Text(
                l10n.errorMessage(error),
                style: context.typography.caption.copyWith(color: colors.statusFailed),
                textAlign: TextAlign.center,
              ),
            ],
            SizedBox(height: 24.h),
            GlobalButton(isFilled: !state.isDownloading, onTap: action, text: label),
          ],
        );
      },
    );
  }
}

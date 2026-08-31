import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/core/widgets/global_text_field.dart';
import 'package:nutq/features/jobs/domain/entities/upload_file.dart';
import 'package:nutq/features/jobs/presentation/cubit/new_job_cubit.dart';
import 'package:nutq/features/jobs/presentation/cubit/new_job_state.dart';

class FileSourceSection extends StatelessWidget {
  const FileSourceSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NewJobCubit, NewJobState>(
      buildWhen: (previous, current) =>
          previous.sourceType != current.sourceType ||
          previous.pickedFile != current.pickedFile ||
          previous.fileTooLarge != current.fileTooLarge,
      builder: (context, state) {
        final isAudio = state.sourceType == NewJobSourceType.audio;
        final file = state.pickedFile;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (file == null)
              _Dropzone(isAudio: isAudio)
            else
              _SelectedFileCard(file: file),
            if (state.fileTooLarge) ...[
              SizedBox(height: 8.h),
              Text(
                context.l10n.newJobFileTooLarge,
                style: context.typography.captionSmall.copyWith(
                  color: context.appColors.statusFailed,
                ),
              ),
            ],
            SizedBox(height: 12.h),
            Text(
              context.l10n.newJobFileNameLabel,
              style: context.typography.bodyMediumTiny.copyWith(
                color: context.appColors.textSecondary,
              ),
            ),
            SizedBox(height: 6.h),
            GlobalTextField(
              hintText: context.l10n.newJobFileNameHint,
              textInputType: TextInputType.text,
              onChanged: context.read<NewJobCubit>().setFilename,
            ),
          ],
        );
      },
    );
  }
}

class _Dropzone extends StatelessWidget {
  const _Dropzone({required this.isAudio});

  final bool isAudio;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final filled = context.isDark;

    return GestureDetector(
      onTap: () => context.read<NewJobCubit>().pickMedia(),
      child: Container(
        height: 110.h,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled
              ? colors.navIndicator
              : colors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: filled
              ? null
              : Border.all(color: colors.primary.withValues(alpha: 0.25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isAudio ? '🎵' : '🎬', style: TextStyle(fontSize: 20.sp)),
            SizedBox(height: 6.h),
            Text(
              isAudio
                  ? context.l10n.newJobChooseAudioFile
                  : context.l10n.newJobChooseVideoFile,
              style: context.typography.labelMedium.copyWith(
                color: filled ? colors.textInverse : colors.primary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              isAudio
                  ? context.l10n.newJobFormatsAudio
                  : context.l10n.newJobFormatsVideo,
              style: context.typography.captionSmall.copyWith(
                color: filled
                     ? colors.textInverse.withValues(alpha: 0.8)
                     : colors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedFileCard extends StatelessWidget {
  const _SelectedFileCard({required this.file});

  final UploadFile file;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: colors.subtle,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: colors.primary.withValues(alpha: 0.15),
            ),
            child: Icon(
              Icons.music_note_rounded,
              size: 20.sp,
              color: colors.primary,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.typography.labelSmall.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  _formatSize(file.sizeBytes),
                  style: context.typography.captionSmall.copyWith(
                    color: colors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => context.read<NewJobCubit>().clearPickedFile(),
            icon: Icon(Icons.close_rounded, size: 18.sp),
            color: colors.textMuted,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  String _formatSize(int bytes) {
    if (bytes >= 1024 * 1024) {
      final mb = bytes / (1024 * 1024);
      return '${mb.toStringAsFixed(mb >= 100 ? 0 : 1)} MB';
    }
    return '${(bytes / 1024).toStringAsFixed(0)} KB';
  }
}

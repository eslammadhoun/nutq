import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nutq/core/extensions/navigation_extension.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/features/jobs/presentation/cubit/new_job_cubit.dart';
import 'package:nutq/features/jobs/presentation/cubit/new_job_state.dart';

class NewJobSheet extends StatelessWidget {
  const NewJobSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return BlocProvider<NewJobCubit>(
      create: (context) => NewJobCubit(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        height: 547.h,
        decoration: BoxDecoration(
          color: colors.navBarBg,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 12.h),
            Container(
              width: 58.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: colors.borderDefault,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
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
                    height: 32.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.appColors.borderDefault,
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/svgs/close.svg',
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            uploadTypeSelector(context),
            SizedBox(height: 16.h),
            launguageSelector(context),
            SizedBox(height: 16.h),
            idempotencyKeyWidget(context),
          ],
        ),
      ),
    );
  }

  Widget uploadTypeSelector(BuildContext context) {
    return BlocBuilder<NewJobCubit, NewJobState>(
      buildWhen: (previous, current) =>
          previous.jobUploadType != current.jobUploadType,
      builder: (BuildContext context, state) {
        final NewJobCubit newJobCubit = context.read<NewJobCubit>();

        return Container(
          padding: EdgeInsets.all(3.h),
          width: double.infinity,
          height: 40.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: context.appColors.subtle,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(JobUploadType.values.length, (index) {
              final bool isSelected =
                  state.jobUploadType == JobUploadType.values[index];

              return InkWell(
                onTap: () => newJobCubit.changeJobUploadType(index: index),
                child: Container(
                  height: 34.w,
                  width: 79.5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: state.jobUploadType.index == index
                        ? context.isDark
                              ? context.appColors.primary
                              : Colors.white
                        : Colors.transparent,
                  ),
                  child: Center(
                    child: Text(
                      _uploadTypeLabel(context, JobUploadType.values[index]),
                      style: context.typography.heading9.copyWith(
                        color: isSelected
                            ? context.isDark
                                  ? Colors.white
                                  : context.appColors.textBrand
                            : context.appColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  String _uploadTypeLabel(BuildContext context, JobUploadType type) {
    final l10n = context.l10n;
    return switch (type) {
      JobUploadType.text => l10n.sourceText,
      JobUploadType.videoFile => l10n.sourceVideo,
      JobUploadType.audio => l10n.sourceAudioFile,
      JobUploadType.youtube => l10n.sourceYoutube,
    };
  }

  Widget launguageSelector(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      width: double.infinity,
      height: 40.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: context.appColors.subtle,
      ),
      child: Row(
        children: [
          Text('🌐', style: context.typography.bodyLarge),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              context.l10n.newJobLanguageLabel,
              style: context.typography.bodyMedium.copyWith(
                color: context.appColors.textPrimary,
              ),
            ),
          ),
          BlocBuilder<NewJobCubit, NewJobState>(
            builder: (context, state) {
              return InkWell(
                onTap: () => context.read<NewJobCubit>().toggleJobLanguage(),
                child: Container(
                  width: 96.w,
                  height: 28.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    color: context.appColors.statusProcessingBg,
                  ),
                  child: Center(
                    child: Text(
                      state.jobLanguage.name == 'ar'
                          ? context.l10n.newJobLanguageArabic
                          : context.l10n.newJobLanguageEnglish,
                      style: context.typography.label2XS.copyWith(
                        color: context.appColors.statusProcessing,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget idempotencyKeyWidget(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      width: double.infinity,
      height: 40.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: context.appColors.subtle,
      ),
      child: Row(
        children: [
          Text('🔑', style: context.typography.bodyLarge),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              context.l10n.newJobIdempotencyKeyLabel,
              style: context.typography.bodyMedium.copyWith(
                color: context.appColors.textPrimary,
              ),
            ),
          ),
          BlocBuilder<NewJobCubit, NewJobState>(
            builder: (context, state) {
              return Switch(
                value: state.idempotencyKey,
                onChanged: (newValue) =>
                    context.read<NewJobCubit>().toggleIdempotencyKey(),
                thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
                  if (states.contains(WidgetState.selected)) {
                    return context.appColors.statusProcessing;
                  }
                  return Colors.white;
                }),
                trackColor: WidgetStateProperty.resolveWith<Color>((states) {
                  return context.appColors.borderDefault;
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/features/jobs/presentation/cubit/new_job_cubit.dart';
import 'package:nutq/features/jobs/presentation/cubit/new_job_state.dart';

class LanguageRow extends StatelessWidget {
  const LanguageRow({super.key});

  @override
  Widget build(BuildContext context) {
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
            buildWhen: (previous, current) =>
                previous.language != current.language,
            builder: (context, state) {
              return InkWell(
                onTap: () => context.read<NewJobCubit>().toggleLanguage(),
                borderRadius: BorderRadius.circular(8.r),
                child: Container(
                  width: 96.w,
                  height: 28.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    color: context.appColors.statusProcessingBg,
                  ),
                  child: Center(
                    child: Text(
                      state.language == JobLanguage.ar
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
}

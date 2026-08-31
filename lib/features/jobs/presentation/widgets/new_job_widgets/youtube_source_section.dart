import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/core/widgets/global_text_field.dart';
import 'package:nutq/features/jobs/presentation/cubit/new_job_cubit.dart';
import 'package:nutq/features/jobs/presentation/cubit/new_job_state.dart';

class YoutubeSourceSection extends StatelessWidget {
  const YoutubeSourceSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.newJobYoutubeUrlLabel,
          style: context.typography.bodyMediumTiny.copyWith(
            color: colors.textSecondary,
          ),
        ),
        SizedBox(height: 6.h),
        GlobalTextField(
          hintText: context.l10n.newJobYoutubeUrlHint,
          textInputType: TextInputType.url,
          onChanged: context.read<NewJobCubit>().setSourceUrl,
        ),
        SizedBox(height: 12.h),
        BlocBuilder<NewJobCubit, NewJobState>(
          buildWhen: (previous, current) =>
              previous.forceWhisper != current.forceWhisper,
          builder: (context, state) {
            return Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: colors.subtle,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.newJobForceWhisper,
                          style: context.typography.labelXS.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          context.l10n.newJobForceWhisperSubtitle,
                          style: context.typography.micro.copyWith(
                            color: colors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: state.forceWhisper,
                    onChanged: (_) =>
                        context.read<NewJobCubit>().toggleForceWhisper(),
                    thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
                      if (states.contains(WidgetState.selected)) {
                        return colors.statusProcessing;
                      }
                      return Colors.white;
                    }),
                    trackColor: WidgetStateProperty.resolveWith<Color>((states) {
                      return colors.borderDefault;
                    }),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

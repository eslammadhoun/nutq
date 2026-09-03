import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/core/widgets/global_text_field.dart';
import 'package:nutq/features/jobs/presentation/cubit/new_job_cubit.dart';

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
      ],
    );
  }
}

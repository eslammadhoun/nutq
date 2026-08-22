import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/core/widgets/global_text_field.dart';
import 'package:nutq/features/jobs/presentation/cubit/jobs_cubit.dart';

class JobsSearchBar extends StatelessWidget {
  const JobsSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: GlobalTextField(
        hintText: 'Search transcriptions...',
        textInputType: TextInputType.text,
        prefixWidget: Icon(
          Icons.search_rounded,
          size: 20.sp,
          color: context.appColors.textMuted,
        ),
        onChanged: (value) => context.read<JobsCubit>().search(value),
      ),
    );
  }
}

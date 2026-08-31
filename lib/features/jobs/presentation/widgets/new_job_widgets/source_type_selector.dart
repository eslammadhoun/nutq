import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/features/jobs/presentation/cubit/new_job_cubit.dart';
import 'package:nutq/features/jobs/presentation/cubit/new_job_state.dart';

class SourceTypeSelector extends StatelessWidget {
  const SourceTypeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NewJobCubit, NewJobState>(
      buildWhen: (previous, current) =>
          previous.sourceType != current.sourceType,
      builder: (BuildContext context, state) {
        final NewJobCubit cubit = context.read<NewJobCubit>();

        return Container(
          padding: EdgeInsets.all(3.h),
          width: double.infinity,
          height: 40.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: context.appColors.subtle,
          ),
          child: Row(
            children: List.generate(NewJobSourceType.values.length, (index) {
              final bool isSelected =
                  state.sourceType == NewJobSourceType.values[index];

              return Expanded(
                child: InkWell(
                  onTap: () => cubit.changeSourceType(index),
                  borderRadius: BorderRadius.circular(10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 34.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: isSelected
                          ? context.isDark
                                ? context.appColors.navIndicator
                                : Colors.white
                          : Colors.transparent,
                    ),
                    child: Text(
                      _label(context, NewJobSourceType.values[index]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.typography.label2XS.copyWith(
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

  String _label(BuildContext context, NewJobSourceType type) {
    final l10n = context.l10n;
    return switch (type) {
      NewJobSourceType.text => l10n.sourceText,
      NewJobSourceType.video => l10n.sourceVideo,
      NewJobSourceType.audio => l10n.sourceAudioFile,
      NewJobSourceType.youtube => l10n.sourceYoutube,
    };
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/features/jobs/presentation/cubit/new_job_cubit.dart';
import 'package:nutq/features/jobs/presentation/cubit/new_job_state.dart';

class TextSourceSection extends StatefulWidget {
  const TextSourceSection({super.key});

  @override
  State<TextSourceSection> createState() => _TextSourceSectionState();
}

class _TextSourceSectionState extends State<TextSourceSection> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: context.read<NewJobCubit>().state.text,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.newJobTextLabel,
          style: context.typography.bodyMediumTiny.copyWith(
            color: colors.textSecondary,
          ),
        ),
        SizedBox(height: 8.h),
        BlocBuilder<NewJobCubit, NewJobState>(
          buildWhen: (previous, current) => previous.text != current.text,
          builder: (context, state) {
            return Container(
              width: double.infinity,
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: colors.subtle,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _controller,
                    minLines: 4,
                    maxLines: 8,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    style: context.typography.bodySmall.copyWith(
                      color: colors.textPrimary,
                    ),
                    cursorColor: colors.primary,
                    onChanged: context.read<NewJobCubit>().setText,
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: context.l10n.newJobTextPlaceholder,
                      hintMaxLines: 2,
                      hintStyle: context.typography.bodySmall.copyWith(
                        color: colors.textMuted,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Text(
                      context.l10n.newJobCharCounter(
                        state.text.length,
                        NewJobState.maxTextLength,
                      ),
                      style: context.typography.captionSmall.copyWith(
                        color: colors.textMuted,
                      ),
                    ),
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

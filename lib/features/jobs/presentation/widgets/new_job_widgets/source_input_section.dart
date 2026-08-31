import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutq/features/jobs/presentation/cubit/new_job_cubit.dart';
import 'package:nutq/features/jobs/presentation/cubit/new_job_state.dart';
import 'package:nutq/features/jobs/presentation/widgets/new_job_widgets/file_source_section.dart';
import 'package:nutq/features/jobs/presentation/widgets/new_job_widgets/text_source_section.dart';
import 'package:nutq/features/jobs/presentation/widgets/new_job_widgets/youtube_source_section.dart';

/// The only section of the sheet that changes with the selected source type.
class SourceInputSection extends StatelessWidget {
  const SourceInputSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NewJobCubit, NewJobState>(
      buildWhen: (previous, current) =>
          previous.sourceType != current.sourceType,
      builder: (context, state) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: KeyedSubtree(
            key: ValueKey<JobSourceType>(state.sourceType),
            child: switch (state.sourceType) {
              JobSourceType.text => const TextSourceSection(),
              JobSourceType.video ||
              JobSourceType.audio => const FileSourceSection(),
              JobSourceType.youtube => const YoutubeSourceSection(),
            },
          ),
        );
      },
    );
  }
}

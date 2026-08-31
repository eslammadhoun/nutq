import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/core/widgets/global_button.dart';
import 'package:nutq/features/jobs/presentation/cubit/new_job_cubit.dart';
import 'package:nutq/features/jobs/presentation/cubit/new_job_state.dart';

class SubmitJobButton extends StatelessWidget {
  const SubmitJobButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NewJobCubit, NewJobState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.canSubmit != current.canSubmit,
      builder: (context, state) {
        final bool isSubmitting = state.status == NewJobStatus.submitting;

        return GlobalButton(
          isFilled: true,
          isLoading: isSubmitting,
          onTap: state.canSubmit
              ? () => context.read<NewJobCubit>().submit()
              : null,
          text: context.l10n.newJobSubmit,
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/extensions/error_l10n_extension.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/core/widgets/global_button.dart';
import 'package:nutq/features/jobs/domain/entities/job_detail_entity.dart';
import 'package:nutq/features/jobs/domain/entities/job_run_status.dart';
import 'package:nutq/features/jobs/presentation/cubit/job_detail_cubit.dart';
import 'package:nutq/features/jobs/presentation/cubit/job_detail_state.dart';
import 'package:nutq/features/jobs/presentation/widgets/job_detail_widgets/job_detail_action_bar.dart';
import 'package:nutq/features/jobs/presentation/widgets/job_detail_widgets/job_detail_app_bar.dart';
import 'package:nutq/features/jobs/presentation/widgets/job_detail_widgets/job_detail_notice.dart';
import 'package:nutq/features/jobs/presentation/widgets/job_detail_widgets/job_progress_card.dart';
import 'package:nutq/features/jobs/presentation/widgets/job_detail_widgets/job_status_hero_card.dart';
import 'package:nutq/features/jobs/presentation/widgets/job_detail_widgets/summary_card.dart';
import 'package:nutq/features/jobs/presentation/widgets/job_detail_widgets/transcript_card.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_failure.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_progress.dart';

class JobDetailScreen extends StatelessWidget {
  const JobDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.page,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            ColoredBox(
              color: context.appColors.surface,
              child: const SafeArea(bottom: false, child: JobDetailAppBar()),
            ),
            Expanded(
              child: BlocBuilder<JobDetailCubit, JobDetailState>(
                builder: (context, state) {
                  final job = state.job;
                  if (job != null) return _JobContent(job: job, state: state);

                  return switch (state.status) {
                    JobDetailStatus.notFound => _Message(
                      text: context.l10n.jobDetailNotFound,
                    ),
                    JobDetailStatus.failure => _Message(
                      text: state.lastError != null
                          ? context.l10n.errorMessage(state.lastError!)
                          : context.l10n.somethingWentWrong,
                      onRetry: () => context.read<JobDetailCubit>().refresh(),
                    ),
                    _ => const Center(child: CircularProgressIndicator()),
                  };
                },
              ),
            ),
            const JobDetailActionBar(),
          ],
        ),
      ),
    );
  }
}

class _JobContent extends StatelessWidget {
  const _JobContent({required this.job, required this.state});

  final JobDetailEntity job;
  final JobDetailState state;

  @override
  Widget build(BuildContext context) {
    final failureKind = job.status == JobRunStatus.failed
        ? job.failureKind
        : null;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        children: [
          JobStatusHeroCard(job: job),
          SizedBox(height: 16.h),
          if (job.status.isActive) ...[
            JobProgressCard(
              progress:
                  state.progress ??
                  const SummarizationProgress(SummarizationStage.preparing),
            ),
            SizedBox(height: 16.h),
          ],
          if (failureKind != null) ...[
            JobDetailNotice(
              kind: JobDetailNoticeKind.error,
              message: _failureMessage(context, failureKind),
            ),
            SizedBox(height: 16.h),
          ],
          if (job.summary?.needsReview ?? false) ...[
            JobDetailNotice(
              kind: JobDetailNoticeKind.warning,
              message: context.l10n.summarizeCheckWarning,
            ),
            SizedBox(height: 16.h),
          ],
          TranscriptCard(job: job),
          SizedBox(height: 16.h),
          SummaryCard(job: job, streamingSummary: state.streamingSummary),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}

String _failureMessage(BuildContext context, SummarizationFailureKind kind) {
  final l10n = context.l10n;
  return switch (kind) {
    SummarizationFailureKind.emptyTranscript => l10n.summarizeErrorEmpty,
    SummarizationFailureKind.modelUnavailable => l10n.summarizeErrorModel,
    SummarizationFailureKind.generationFailed => l10n.summarizeErrorGeneration,
    SummarizationFailureKind.interrupted => l10n.summarizeErrorInterrupted,
  };
}

class _Message extends StatelessWidget {
  const _Message({required this.text, this.onRetry});

  final String text;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: context.typography.bodySmall.copyWith(
                color: context.appColors.textSecondary,
              ),
            ),
            if (onRetry != null) ...[
              SizedBox(height: 16.h),
              GlobalButton(
                isFilled: false,
                text: context.l10n.retry,
                onTap: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

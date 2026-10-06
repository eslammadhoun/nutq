import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/extensions/error_l10n_extension.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/core/widgets/global_button.dart';
import 'package:nutq/features/jobs/domain/entities/job_detail_entity.dart';
import 'package:nutq/features/jobs/domain/entities/job_failure.dart';
import 'package:nutq/features/jobs/domain/entities/job_progress.dart';
import 'package:nutq/features/jobs/domain/entities/job_run_status.dart';
import 'package:nutq/features/jobs/domain/entities/job_stage.dart';
import 'package:nutq/features/jobs/presentation/cubit/job_detail_cubit.dart';
import 'package:nutq/features/jobs/presentation/cubit/job_detail_state.dart';
import 'package:nutq/features/jobs/presentation/utils/job_display_format.dart';
import 'package:nutq/features/jobs/presentation/widgets/job_detail_widgets/job_detail_action_bar.dart';
import 'package:nutq/features/jobs/presentation/widgets/job_detail_widgets/job_detail_app_bar.dart';
import 'package:nutq/features/jobs/presentation/widgets/job_detail_widgets/job_detail_notice.dart';
import 'package:nutq/features/jobs/presentation/widgets/job_detail_widgets/job_progress_card.dart';
import 'package:nutq/features/jobs/presentation/widgets/job_detail_widgets/job_status_hero_card.dart';
import 'package:nutq/features/jobs/presentation/widgets/job_detail_widgets/summary_card.dart';
import 'package:nutq/features/jobs/presentation/widgets/job_detail_widgets/transcript_card.dart';

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
              // Rebuilds only when the screen switches between loading, content
              // and an error; the content below listens to just what it shows.
              child: BlocBuilder<JobDetailCubit, JobDetailState>(
                buildWhen: (previous, current) =>
                    previous.status != current.status ||
                    (previous.job == null) != (current.job == null),
                builder: (context, state) {
                  if (state.status == JobDetailStatus.notFound) {
                    return _Message(text: context.l10n.jobDetailNotFound);
                  }
                  if (state.job != null) return const _JobContent();
                  return switch (state.status) {
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

/// The job's cards. Each section listens only to the slice of state it shows,
/// so a progress tick or a streamed word never rebuilds (and re-lays-out) the
/// transcript.
class _JobContent extends StatelessWidget {
  const _JobContent();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        children: [
          BlocSelector<JobDetailCubit, JobDetailState, JobDetailEntity>(
            selector: (state) => state.job!,
            builder: (context, job) => JobStatusHeroCard(job: job),
          ),
          SizedBox(height: 16.h),
          const _ProgressSection(),
          const _NoticesSection(),
          BlocSelector<JobDetailCubit, JobDetailState, ({JobDetailEntity job, String? live})>(
            selector: (state) => (job: state.job!, live: state.streamingTranscript),
            builder: (context, data) =>
                TranscriptCard(job: data.job, streamingTranscript: data.live),
          ),
          SizedBox(height: 16.h),
          BlocBuilder<JobDetailCubit, JobDetailState>(
            buildWhen: (previous, current) =>
                previous.job != current.job ||
                previous.streamingSummary != current.streamingSummary,
            builder: (context, state) =>
                SummaryCard(job: state.job!, streamingSummary: state.streamingSummary),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}

class _ProgressSection extends StatelessWidget {
  const _ProgressSection();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<JobDetailCubit, JobDetailState, ({bool active, JobProgress? progress})>(
      selector: (state) => (active: state.job!.status.isActive, progress: state.progress),
      builder: (context, data) {
        if (!data.active) return const SizedBox.shrink();
        return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: JobProgressCard(
            progress: data.progress ?? const JobProgress(JobStage.preparing, fraction: 0.02),
          ),
        );
      },
    );
  }
}

class _NoticesSection extends StatelessWidget {
  const _NoticesSection();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      JobDetailCubit,
      JobDetailState,
      ({JobFailureKind? failure, bool needsReview})
    >(
      selector: (state) {
        final job = state.job!;
        return (
          failure: job.status == JobRunStatus.failed ? job.failureKind : null,
          needsReview: job.summary?.needsReview ?? false,
        );
      },
      builder: (context, data) => Column(
        children: [
          if (data.failure != null)
            Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: JobDetailNotice(
                kind: JobDetailNoticeKind.error,
                message: jobFailureMessage(context.l10n, data.failure!),
              ),
            ),
          if (data.needsReview)
            Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: JobDetailNotice(
                kind: JobDetailNoticeKind.warning,
                message: context.l10n.jobSummaryNeedsReview,
              ),
            ),
        ],
      ),
    );
  }
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

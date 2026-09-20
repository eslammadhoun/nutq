import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/extensions/error_l10n_extension.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/core/widgets/global_button.dart';
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
    return BlocListener<JobDetailCubit, JobDetailState>(
      listenWhen: (previous, current) =>
          current.cancelError != null &&
          previous.cancelErrorToken != current.cancelErrorToken,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(context.l10n.jobsErrorMessage(state.cancelError!)),
              backgroundColor: context.appColors.statusFailed,
            ),
          );
      },
      child: Scaffold(
        backgroundColor: context.appColors.base,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const JobDetailAppBar(),
              Expanded(
                child: BlocBuilder<JobDetailCubit, JobDetailState>(
                  builder: (context, state) {
                    final job = state.job;

                    if (state.status == JobDetailStatus.loading && job == null) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.status == JobDetailStatus.failure && job == null) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 32.w),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                state.lastError != null
                                    ? context.l10n.jobsErrorMessage(state.lastError!)
                                    : context.l10n.somethingWentWrong,
                                textAlign: TextAlign.center,
                                style: context.typography.bodySmall.copyWith(
                                  color: context.appColors.textSecondary,
                                ),
                              ),
                              SizedBox(height: 16.h),
                              GlobalButton(
                                isFilled: false,
                                text: context.l10n.retry,
                                onTap: () => context.read<JobDetailCubit>().refresh(),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                      child: Column(
                        children: [
                          if (state.connectionStatus == JobConnectionStatus.reconnecting)
                            Padding(
                              padding: EdgeInsets.only(bottom: 12.h),
                              child: const _ReconnectingBanner(),
                            ),
                          JobStatusHeroCard(job: job!),
                          SizedBox(height: 16.h),
                          if (_isRunning(job.status)) ...[
                            JobProgressCard(
                              progress: state.progress ??
                                  const SummarizationProgress(SummarizationStage.preparing),
                            ),
                            SizedBox(height: 16.h),
                          ],
                          if (state.failureKind != null) ...[
                            JobDetailNotice(
                              kind: JobDetailNoticeKind.error,
                              message: _failureMessage(context, state.failureKind!),
                            ),
                            SizedBox(height: 16.h),
                          ],
                          if (state.summaryNeedsReview) ...[
                            JobDetailNotice(
                              kind: JobDetailNoticeKind.warning,
                              message: context.l10n.summarizeCheckWarning,
                            ),
                            SizedBox(height: 16.h),
                          ],
                          TranscriptCard(
                            job: job,
                            transcriptText: state.transcriptText,
                            isLoadingTranscriptText: state.isLoadingTranscriptText,
                            streamingTranscript: state.streamingTranscript,
                          ),
                          SizedBox(height: 16.h),
                          SummaryCard(
                            job: job,
                            streamingSummary: state.streamingSummary,
                            takeaways: state.summaryTakeaways,
                          ),
                          SizedBox(height: 16.h),
                        ],
                      ),
                    );
                  },
                ),
              ),
              JobDetailActionBar(),
            ],
          ),
        ),
      ),
    );
  }
}

bool _isRunning(String rawStatus) => rawStatus == 'pending' || rawStatus == 'summarizing';

String _failureMessage(BuildContext context, SummarizationFailureKind kind) {
  final l10n = context.l10n;
  return switch (kind) {
    SummarizationFailureKind.emptyTranscript => l10n.summarizeErrorEmpty,
    SummarizationFailureKind.modelUnavailable => l10n.summarizeErrorModel,
    SummarizationFailureKind.generationFailed => l10n.summarizeErrorGeneration,
  };
}

class _ReconnectingBanner extends StatelessWidget {
  const _ReconnectingBanner();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: colors.statusProcessingBg,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 14.w,
            height: 14.w,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colors.statusProcessing,
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            context.l10n.jobDetailReconnecting,
            style: context.typography.captionSmall.copyWith(
              color: colors.statusProcessing,
            ),
          ),
        ],
      ),
    );
  }
}

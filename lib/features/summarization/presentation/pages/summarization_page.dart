import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_failure.dart';
import 'package:nutq/features/summarization/domain/entities/summary_length.dart';
import 'package:nutq/features/summarization/presentation/bloc/summarization_bloc.dart';
import 'package:nutq/features/summarization/presentation/bloc/summarization_event.dart';
import 'package:nutq/features/summarization/presentation/bloc/summarization_state.dart';
import 'package:nutq/features/summarization/presentation/widgets/summarization_input_view.dart';
import 'package:nutq/features/summarization/presentation/widgets/summarization_progress_view.dart';
import 'package:nutq/features/summarization/presentation/widgets/summarization_result_view.dart';

/// On-device summarization screen. Expects a [SummarizationBloc] above it.
class SummarizationPage extends StatefulWidget {
  const SummarizationPage({super.key});

  @override
  State<SummarizationPage> createState() => _SummarizationPageState();
}

class _SummarizationPageState extends State<SummarizationPage> {
  final _controller = TextEditingController();
  SummaryLength _length = SummaryLength.medium;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bloc = context.read<SummarizationBloc>();
    return Scaffold(
      backgroundColor: context.appColors.subtle,
      appBar: AppBar(
        title: Text(l10n.summarizeScreenTitle),
        backgroundColor: context.appColors.subtle,
        elevation: 0,
      ),
      body: SafeArea(
        child: BlocBuilder<SummarizationBloc, SummarizationState>(
          builder: (context, state) => switch (state) {
            SummarizationRunning(:final progress) => SummarizationProgressView(
              progress: progress,
              onCancel: () => bloc.add(const SummarizationCancelRequested()),
            ),
            SummarizationSuccess(:final result) => SummarizationResultView(
              result: result,
              onNew: () => bloc.add(const SummarizationReset()),
            ),
            _ => SummarizationInputView(
              controller: _controller,
              length: _length,
              onLengthChanged: (value) => setState(() => _length = value),
              onSubmit: () => bloc.add(
                SummarizationStarted(transcript: _controller.text, length: _length),
              ),
              message: _messageFor(context, state),
              messageIsError: state is! SummarizationCancelled,
            ),
          },
        ),
      ),
    );
  }

  String? _messageFor(BuildContext context, SummarizationState state) {
    final l10n = context.l10n;
    return switch (state) {
      SummarizationCancelled() => l10n.summarizeCancelled,
      SummarizationFailed(:final kind) => switch (kind) {
        SummarizationFailureKind.emptyTranscript => l10n.summarizeErrorEmpty,
        SummarizationFailureKind.modelUnavailable => l10n.summarizeErrorModel,
        SummarizationFailureKind.generationFailed => l10n.summarizeErrorGeneration,
      },
      _ => null,
    };
  }
}

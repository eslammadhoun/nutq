import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/core/widgets/global_button.dart';
import 'package:nutq/features/summarization/domain/entities/summary_length.dart';

class SummarizationInputView extends StatelessWidget {
  const SummarizationInputView({
    super.key,
    required this.controller,
    required this.length,
    required this.onLengthChanged,
    required this.onSubmit,
    this.message,
    this.messageIsError = true,
  });

  final TextEditingController controller;
  final SummaryLength length;
  final ValueChanged<SummaryLength> onLengthChanged;
  final VoidCallback onSubmit;

  /// Localized status text shown above the field (failure / cancelled).
  final String? message;
  final bool messageIsError;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;
    return ListView(
      padding: EdgeInsetsDirectional.fromSTEB(20.w, 16.h, 20.w, 24.h),
      children: [
        if (message != null) ...[
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: messageIsError ? colors.statusFailedBg : colors.statusCancelledBg,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              message!,
              style: context.typography.bodySmall.copyWith(
                color: messageIsError ? colors.statusFailed : colors.statusCancelled,
              ),
            ),
          ),
          SizedBox(height: 12.h),
        ],
        Container(
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: colors.borderSubtle),
          ),
          child: TextField(
            controller: controller,
            minLines: 10,
            maxLines: 16,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            style: context.typography.bodyBase.copyWith(color: colors.textPrimary),
            decoration: InputDecoration(
              hintText: l10n.summarizeTranscriptHint,
              hintStyle: context.typography.bodyBase.copyWith(color: colors.textMuted),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16.r),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Wrap(
          spacing: 8.w,
          children: [
            for (final option in SummaryLength.values)
              ChoiceChip(
                label: Text(_label(context, option)),
                selected: option == length,
                onSelected: (_) => onLengthChanged(option),
              ),
          ],
        ),
        SizedBox(height: 24.h),
        Center(
          child: ListenableBuilder(
            listenable: controller,
            builder: (context, _) => Opacity(
              opacity: controller.text.trim().isEmpty ? 0.5 : 1,
              child: GlobalButton(
                isFilled: true,
                text: l10n.summarizeAction,
                onTap: controller.text.trim().isEmpty ? null : onSubmit,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _label(BuildContext context, SummaryLength option) {
    final l10n = context.l10n;
    return switch (option) {
      SummaryLength.short => l10n.summarizeLengthShort,
      SummaryLength.medium => l10n.summarizeLengthMedium,
      SummaryLength.detailed => l10n.summarizeLengthDetailed,
    };
  }
}

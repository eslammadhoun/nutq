import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/core/widgets/global_button.dart';
import 'package:nutq/features/summarization/domain/entities/summary_result.dart';

class SummarizationResultView extends StatelessWidget {
  const SummarizationResultView({super.key, required this.result, required this.onNew});

  final SummaryResult result;
  final VoidCallback onNew;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;
    return ListView(
      padding: EdgeInsetsDirectional.fromSTEB(20.w, 16.h, 20.w, 24.h),
      children: [
        if (result.validation.isSuspicious) ...[
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: colors.statusWarningBg,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              l10n.summarizeCheckWarning,
              style: context.typography.bodySmall.copyWith(color: colors.statusWarning),
            ),
          ),
          SizedBox(height: 12.h),
        ],
        _Section(
          title: l10n.summarizeResultTitle,
          child: SelectableText(
            result.summary,
            style: context.typography.bodyBase.copyWith(color: colors.textPrimary, height: 1.6),
          ),
        ),
        if (result.keyPoints.isNotEmpty) ...[
          SizedBox(height: 12.h),
          _Section(title: l10n.summarizeKeyPoints, child: _Bullets(result.keyPoints)),
        ],
        if (result.importantFacts.isNotEmpty) ...[
          SizedBox(height: 12.h),
          _Section(title: l10n.summarizeImportantFacts, child: _Bullets(result.importantFacts)),
        ],
        SizedBox(height: 24.h),
        Center(
          child: GlobalButton(isFilled: false, text: l10n.summarizeNewSummary, onTap: onNew),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: context.typography.heading5.copyWith(color: colors.textPrimary)),
          SizedBox(height: 8.h),
          child,
        ],
      ),
    );
  }
}

class _Bullets extends StatelessWidget {
  const _Bullets(this.items);

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final style = context.typography.bodyBase.copyWith(color: context.appColors.textPrimary);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items)
          Padding(
            padding: EdgeInsetsDirectional.only(bottom: 6.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('•  ', style: style),
                Expanded(child: Text(item, style: style)),
              ],
            ),
          ),
      ],
    );
  }
}

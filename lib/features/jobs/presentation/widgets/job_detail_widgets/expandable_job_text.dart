import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/extensions/theme_extension.dart';

/// Tap-to-expand/collapse body text for the Job Detail transcript/summary
/// cards. Only becomes tappable once the text actually overflows
/// [collapsedMaxLines] at the available width — short text renders as a
/// plain, non-interactive block with no "Show more" affordance.
class ExpandableJobText extends StatefulWidget {
  const ExpandableJobText(
    this.text, {
    super.key,
    required this.style,
    required this.textDirection,
    this.collapsedMaxLines = 4,
  });

  final String text;
  final TextStyle style;
  final TextDirection textDirection;
  final int collapsedMaxLines;

  @override
  State<ExpandableJobText> createState() => _ExpandableJobTextState();
}

class _ExpandableJobTextState extends State<ExpandableJobText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;

    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: widget.text, style: widget.style),
          maxLines: widget.collapsedMaxLines,
          textDirection: widget.textDirection,
        )..layout(maxWidth: constraints.maxWidth);
        final overflows = painter.didExceedMaxLines;

        final textWidget = Text(
          widget.text,
          maxLines: _expanded ? null : widget.collapsedMaxLines,
          overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: widget.style,
        );

        if (!overflows) {
          return Directionality(textDirection: widget.textDirection, child: textWidget);
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _expanded = !_expanded),
          child: Directionality(
            textDirection: widget.textDirection,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                textWidget,
                SizedBox(height: 6.h),
                Text(
                  _expanded ? l10n.jobDetailShowLess : l10n.jobDetailShowMore,
                  style: context.typography.captionSmall.copyWith(color: colors.accentBlue),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

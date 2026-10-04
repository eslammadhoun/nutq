import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/extensions/theme_extension.dart';

/// Tap-to-expand/collapse body text for the Job Detail transcript/summary
/// cards. Only becomes tappable once the text actually overflows
/// [collapsedMaxLines] at the available width — short text renders as a
/// plain, non-interactive block with no "Show more" affordance.
class ExpandableJobText extends StatefulWidget {
  /// A collapsed view needs only enough text to fill [collapsedMaxLines]; laying
  /// out a whole transcript (tens of thousands of words) just to show four
  /// lines costs tens to hundreds of milliseconds on every rebuild.
  static const previewChars = 1000;

  const ExpandableJobText(
    this.text, {
    super.key,
    required this.style,
    required this.textDirection,
    this.collapsedMaxLines = 4,
    this.forceExpanded = false,
  });

  final String text;
  final TextStyle style;
  final TextDirection textDirection;
  final int collapsedMaxLines;

  /// Shows the full text with no toggle — used while text is still streaming
  /// in, so new words are visible as they arrive.
  final bool forceExpanded;

  @override
  State<ExpandableJobText> createState() => _ExpandableJobTextState();
}

class _ExpandableJobTextState extends State<ExpandableJobText> {
  bool _expanded = false;

  @override
  void didUpdateWidget(ExpandableJobText oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Streaming just finished: stay expanded so the text the user was
    // reading doesn't snap shut; the toggle can still collapse it.
    if (oldWidget.forceExpanded && !widget.forceExpanded) _expanded = true;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;

    final tooLongForPreview = widget.text.length > ExpandableJobText.previewChars;
    final preview = tooLongForPreview ? _preview(widget.text) : widget.text;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Measure the preview, never the whole text; text longer than the
        // preview always overflows.
        final painter = TextPainter(
          text: TextSpan(text: preview, style: widget.style),
          maxLines: widget.collapsedMaxLines,
          textDirection: widget.textDirection,
        )..layout(maxWidth: constraints.maxWidth);
        final overflows = tooLongForPreview || painter.didExceedMaxLines;

        final textWidget = Text(
          _expanded ? widget.text : preview,
          maxLines: _expanded ? null : widget.collapsedMaxLines,
          overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: widget.style,
        );

        if (widget.forceExpanded) {
          return Directionality(
            textDirection: widget.textDirection,
            child: Text(widget.text, style: widget.style),
          );
        }

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

/// The first [ExpandableJobText.previewChars] characters, cut at a word
/// boundary so a character is never split.
String _preview(String text) {
  final cut = text.lastIndexOf(RegExp(r'\s'), ExpandableJobText.previewChars);
  return text.substring(0, cut > 0 ? cut : ExpandableJobText.previewChars);
}

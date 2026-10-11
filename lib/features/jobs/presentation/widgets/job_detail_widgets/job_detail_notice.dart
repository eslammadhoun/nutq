import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/extensions/theme_extension.dart';

enum JobDetailNoticeKind { error, warning }

/// Inline message strip on the Job Detail screen (failure / review warning).
class JobDetailNotice extends StatelessWidget {
  const JobDetailNotice({super.key, required this.message, required this.kind});

  final String message;
  final JobDetailNoticeKind kind;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isError = kind == JobDetailNoticeKind.error;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: isError ? colors.statusFailedBg : colors.statusWarningBg,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        message,
        style: context.typography.bodySmall.copyWith(
          color: isError ? colors.statusFailed : colors.statusWarning,
        ),
      ),
    );
  }
}

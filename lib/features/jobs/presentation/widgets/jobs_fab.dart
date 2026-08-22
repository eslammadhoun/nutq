import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/extensions/theme_extension.dart';

class JobsFab extends StatelessWidget {
  const JobsFab({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withValues(alpha: 0.45),
              blurRadius: 16,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: FloatingActionButton(
          elevation: 0,
          backgroundColor: colors.primary,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('New job — coming soon')),
            );
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(Icons.add_rounded, color: colors.textInverse),
        ),
      ),
    );
  }
}

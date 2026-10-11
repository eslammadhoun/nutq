import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/extensions/theme_extension.dart';

/// The design's on/off switch: a 44×24 pill with a white knob, blue when on.
/// Dimmed and inert when [onChanged] is null.
class AppSwitch extends StatelessWidget {
  const AppSwitch({super.key, required this.value, required this.onChanged, this.label});

  final bool value;
  final ValueChanged<bool>? onChanged;

  /// What the switch controls, for screen readers.
  final String? label;

  static const _duration = Duration(milliseconds: 180);

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Semantics(
      label: label,
      toggled: value,
      enabled: onChanged != null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onChanged == null ? null : () => onChanged!(!value),
        child: AnimatedOpacity(
          duration: _duration,
          opacity: onChanged == null ? 0.5 : 1,
          child: AnimatedContainer(
            duration: _duration,
            curve: Curves.easeOut,
            width: 44.w,
            height: 24.w,
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: value ? colors.navIndicator : colors.iconMuted,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: AnimatedAlign(
              duration: _duration,
              curve: Curves.easeOut,
              alignment: value ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
              child: Container(
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(color: colors.textInverse, shape: BoxShape.circle),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The app's icons: Iconly V3 (Regular family), as one-color SVGs that
/// [AppIcon] tints. Light (outline) for idle, Bold (filled) for selected,
/// Bulk (two-tone) for accents.
abstract final class AppIcons {
  static const home = 'assets/svgs/home.svg';
  static const homeActive = 'assets/svgs/home_active.svg';
  static const alerts = 'assets/svgs/alerts.svg';
  static const alertsActive = 'assets/svgs/alerts_active.svg';
  static const profile = 'assets/svgs/profile.svg';
  static const profileActive = 'assets/svgs/profile_active.svg';
  static const audio = 'assets/svgs/audio.svg';
  static const video = 'assets/svgs/video.svg';
  static const transcript = 'assets/svgs/transcript.svg';
  static const summary = 'assets/svgs/summary.svg';
}

/// An [AppIcons] SVG, [size] square, in [color]. Two-tone icons keep their
/// lighter part, since the tint keeps each shape's opacity.
class AppIcon extends StatelessWidget {
  const AppIcon(this.path, {super.key, required this.size, required this.color});

  final String path;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    path,
    width: size,
    height: size,
    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
  );
}

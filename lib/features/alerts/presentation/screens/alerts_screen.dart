import 'package:flutter/material.dart';
import 'package:nutq/core/extensions/theme_extension.dart';

// TODO(alerts): placeholder until the Alerts screen is designed and wired
// to a real notifications source.
class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.subtle,
      body: SafeArea(
        child: Center(
          child: Text(
            context.l10n.alertsComingSoon,
            style: context.typography.bodyBase.copyWith(
              color: context.appColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/features/auth/presentation/widgets/auth_footer.dart';

class RegisterFooter extends StatelessWidget {
  const RegisterFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AuthFooter(
      staticText: l10n.registerFooterPrompt,
      actionText: l10n.registerFooterAction,
      onActionTap: () => Navigator.pop(context),
    );
  }
}

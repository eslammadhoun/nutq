import 'package:flutter/material.dart';
import 'package:nutq/features/auth/presentation/widgets/auth_footer.dart';

class RegisterFooter extends StatelessWidget {
  const RegisterFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthFooter(
      staticText: 'Already have an account? ',
      actionText: 'Log in',
      onActionTap: () => Navigator.pop(context),
    );
  }
}

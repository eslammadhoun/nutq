import 'package:flutter/material.dart';
import 'package:nutq/core/di/dependency_injection.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/core/routing/routes.dart';
import 'package:nutq/core/widgets/global_button.dart';
import 'package:nutq/features/auth/domain/repositories/auth_repository.dart';

// TODO(profile): placeholder until the Profile screen is designed.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.subtle,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Profile — coming soon',
                style: context.typography.bodyBase.copyWith(
                  color: context.appColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              GlobalButton(
                isFilled: false,
                text: 'Log out',
                onTap: () async {
                  await sl<AuthRepository>().logout();
                  if (!context.mounted) return;
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    Routes.login,
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutq/core/di/dependency_injection.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/core/locale/locale_cubit.dart';
import 'package:nutq/core/routing/routes.dart';
import 'package:nutq/core/widgets/global_button.dart';
import 'package:nutq/features/auth/domain/repositories/auth_repository.dart';

// TODO(profile): placeholder until the Profile screen is designed.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: context.appColors.subtle,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.profileComingSoon,
                style: context.typography.bodyBase.copyWith(
                  color: context.appColors.textSecondary,
                ),
              ),
              // TODO: temporary language toggle for testing — remove before release.
              BlocBuilder<LocaleCubit, Locale?>(
                builder: (context, locale) {
                  final isAr = locale?.languageCode == 'ar';
                  return TextButton(
                    onPressed: () => context.read<LocaleCubit>().setLocale(
                          Locale(isAr ? 'en' : 'ar'),
                        ),
                    child: Text(isAr ? 'Switch to English' : 'التبديل إلى العربية'),
                  );
                },
              ),
              const SizedBox(height: 16),
              GlobalButton(
                isFilled: false,
                text: l10n.profileLogOut,
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

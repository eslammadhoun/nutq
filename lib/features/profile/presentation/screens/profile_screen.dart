import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/core/locale/locale_cubit.dart';
import 'package:nutq/core/routing/routes.dart';

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
              TextButton(
                onPressed: () => Navigator.of(context).pushNamed(Routes.models),
                child: Text(l10n.profileModels),
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
            ],
          ),
        ),
      ),
    );
  }
}

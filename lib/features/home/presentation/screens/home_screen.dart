import 'package:flutter/material.dart';
import 'package:nutq/core/di/dependency_injection.dart';
import 'package:nutq/core/routing/routes.dart';
import 'package:nutq/features/auth/domain/repositories/auth_repository.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Home Screen'),
            const SizedBox(height: 16),
            // TODO: temp logout button for testing — remove later
            ElevatedButton(
              onPressed: () async {
                await sl<AuthRepository>().logout();
                if (!context.mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Routes.login,
                  (route) => false,
                );
              },
              child: const Text('Logout (temp)'),
            ),
          ],
        ),
      ),
    );
  }
}

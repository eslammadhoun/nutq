import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/routing/routes.dart';
import 'package:nutq/features/auth/presentaion/ui/login/widgets/login_form.dart';
import 'package:nutq/features/auth/presentaion/ui/login/widgets/login_welcome.dart';
import 'package:nutq/features/auth/presentaion/widgets/auth_footer.dart';
import 'package:nutq/features/auth/presentaion/widgets/auth_header.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 25.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AuthHeader(),
              const LoginWelcome(),
              const LoginForm(),
              AuthFooter(
                staticText: "Don't have an account? ",
                actionText: 'Sign up',
                onActionTap: () =>
                    Navigator.pushNamed(context, Routes.register),
              ),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }
}

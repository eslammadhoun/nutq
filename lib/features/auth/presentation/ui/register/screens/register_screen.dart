import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/features/auth/presentaion/ui/register/widgets/register_footer.dart';
import 'package:nutq/features/auth/presentaion/ui/register/widgets/register_form.dart';
import 'package:nutq/features/auth/presentaion/ui/register/widgets/register_header.dart';
import 'package:nutq/features/auth/presentaion/ui/register/widgets/register_welcome.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

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
              const RegisterHeader(),
              const RegisterWelcome(),
              const RegisterForm(),
              const RegisterFooter(),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }
}

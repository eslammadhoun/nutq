import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/core/utils/validators.dart';
import 'package:nutq/core/widgets/global_text_field.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late bool _showPassword;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _showPassword = false;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20.h),
          Text(
            'Email address',
            style: context.typography.labelSmall.copyWith(
              color: context.appColors.textSecondary,
            ),
          ),
          SizedBox(height: 5.h),
          GlobalTextField(
            controller: _emailController,
            hintText: 'Enter your email',
            textInputType: TextInputType.emailAddress,
            validator: Validators.validateEmail,
          ),
          SizedBox(height: 24.h),
          Text(
            'Password',
            style: context.typography.labelSmall.copyWith(
              color: context.appColors.textSecondary,
            ),
          ),
          SizedBox(height: 5.h),
          GlobalTextField(
            controller: _passwordController,
            hintText: '••••••••',
            textInputType: TextInputType.visiblePassword,
            obscureText: !_showPassword,
            suffixWidget: GestureDetector(
              onTap: () => setState(() => _showPassword = !_showPassword),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  _showPassword ? 'Hide' : 'Show',
                  style: context.typography.labelSmall.copyWith(
                    color: context.appColors.textBrand,
                  ),
                ),
              ),
            ),
            validator: Validators.validatePassword,
          ),
          SizedBox(height: 32.h),
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: () => _formKey.currentState!.validate()
                  ? _handleLogin()
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.appColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'Log In',
                style: context.typography.labelLarge.copyWith(
                  color: context.appColors.textInverse,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleLogin() {
    // TODO: Wire up login API call
  }
}
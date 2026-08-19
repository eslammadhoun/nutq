import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/core/utils/validators.dart';
import 'package:nutq/core/widgets/global_text_field.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  late bool _showPassword;
  late bool _showConfirmPassword;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _showPassword = false;
    _showConfirmPassword = false;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
            'Username',
            style: context.typography.labelSmall.copyWith(
              color: context.appColors.textSecondary,
            ),
          ),
          SizedBox(height: 5.h),
          GlobalTextField(
            controller: _usernameController,
            hintText: 'e.g. ahmed_ali',
            textInputType: TextInputType.text,
            validator: Validators.validateUsername,
          ),
          SizedBox(height: 24.h),
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
          SizedBox(height: 24.h),
          Text(
            'Confirm password',
            style: context.typography.labelSmall.copyWith(
              color: context.appColors.textSecondary,
            ),
          ),
          SizedBox(height: 5.h),
          GlobalTextField(
            controller: _confirmPasswordController,
            hintText: 'Repeat your password',
            textInputType: TextInputType.visiblePassword,
            obscureText: !_showConfirmPassword,
            suffixWidget: GestureDetector(
              onTap: () =>
                  setState(() => _showConfirmPassword = !_showConfirmPassword),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  _showConfirmPassword ? 'Hide' : 'Show',
                  style: context.typography.labelSmall.copyWith(
                    color: context.appColors.textBrand,
                  ),
                ),
              ),
            ),
            validator: (value) =>
                Validators.validateConfirmPassword(value, _passwordController.text),
          ),
          SizedBox(height: 32.h),
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: () => _formKey.currentState!.validate()
                  ? _handleCreateAccount()
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.appColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'Create Account',
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

  void _handleCreateAccount() {
    // TODO: Wire up registration API call
  }
}

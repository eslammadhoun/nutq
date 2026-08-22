import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/core/routing/routes.dart';
import 'package:nutq/core/utils/validators.dart';
import 'package:nutq/core/widgets/global_button.dart';
import 'package:nutq/core/widgets/global_text_field.dart';
import 'package:nutq/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:nutq/features/auth/data/models/login_request.dart';

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
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.home,
            (route) => false,
          );
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: context.appColors.statusFailed,
            ),
          );
        } else if (state is AuthFieldErrors) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errors.values.first),
              backgroundColor: context.appColors.statusFailed,
            ),
          );
        }
      },
      child: Form(
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
            BlocBuilder<AuthCubit, AuthState>(
              buildWhen: (previous, current) =>
                  previous is AuthLoading || current is AuthLoading,
              builder: (context, state) {
                final isLoading = state is AuthLoading;
                return GlobalButton(
                  isFilled: true,
                  isLoading: isLoading,
                  onTap: isLoading
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            context.read<AuthCubit>().login(
                              LoginRequest(
                                email: _emailController.text.trim(),
                                password: _passwordController.text,
                              ),
                            );
                          }
                        },
                  text: 'Log In',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

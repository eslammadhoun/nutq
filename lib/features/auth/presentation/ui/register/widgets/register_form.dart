import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/extensions/error_l10n_extension.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/core/routing/routes.dart';
import 'package:nutq/core/utils/validators.dart';
import 'package:nutq/core/widgets/global_button.dart';
import 'package:nutq/core/widgets/global_text_field.dart';
import 'package:nutq/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:nutq/features/auth/data/models/register_request.dart';

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
    final l10n = context.l10n;
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
              content: Text(context.l10n.authErrorMessage(state.error)),
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
              l10n.registerUsernameLabel,
              style: context.typography.labelSmall.copyWith(
                color: context.appColors.textSecondary,
              ),
            ),
            SizedBox(height: 5.h),
            GlobalTextField(
              controller: _usernameController,
              hintText: l10n.registerUsernameHint,
              textInputType: TextInputType.text,
              validator: (value) => Validators.validateUsername(value, l10n),
            ),
            SizedBox(height: 24.h),
            Text(
              l10n.authEmailLabel,
              style: context.typography.labelSmall.copyWith(
                color: context.appColors.textSecondary,
              ),
            ),
            SizedBox(height: 5.h),
            GlobalTextField(
              controller: _emailController,
              hintText: l10n.authEmailHint,
              textInputType: TextInputType.emailAddress,
              validator: (value) => Validators.validateEmail(value, l10n),
            ),
            SizedBox(height: 24.h),
            Text(
              l10n.authPasswordLabel,
              style: context.typography.labelSmall.copyWith(
                color: context.appColors.textSecondary,
              ),
            ),
            SizedBox(height: 5.h),
            GlobalTextField(
              controller: _passwordController,
              hintText: l10n.authPasswordHidden,
              textInputType: TextInputType.visiblePassword,
              obscureText: !_showPassword,
              suffixWidget: GestureDetector(
                onTap: () => setState(() => _showPassword = !_showPassword),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Text(
                    _showPassword ? l10n.authHidePassword : l10n.authShowPassword,
                    style: context.typography.labelSmall.copyWith(
                      color: context.appColors.textBrand,
                    ),
                  ),
                ),
              ),
              validator: (value) => Validators.validatePassword(value, l10n),
            ),
            SizedBox(height: 24.h),
            Text(
              l10n.registerConfirmPasswordLabel,
              style: context.typography.labelSmall.copyWith(
                color: context.appColors.textSecondary,
              ),
            ),
            SizedBox(height: 5.h),
            GlobalTextField(
              controller: _confirmPasswordController,
              hintText: l10n.registerConfirmPasswordHint,
              textInputType: TextInputType.visiblePassword,
              obscureText: !_showConfirmPassword,
              suffixWidget: GestureDetector(
                onTap: () =>
                    setState(() => _showConfirmPassword = !_showConfirmPassword),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Text(
                    _showConfirmPassword ? l10n.authHidePassword : l10n.authShowPassword,
                    style: context.typography.labelSmall.copyWith(
                      color: context.appColors.textBrand,
                    ),
                  ),
                ),
              ),
              validator: (value) => Validators.validateConfirmPassword(
                value,
                _passwordController.text,
                l10n,
              ),
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
                            context.read<AuthCubit>().register(
                              RegisterRequest(
                                name: _usernameController.text.trim(),
                                email: _emailController.text.trim(),
                                password: _passwordController.text,
                              ),
                            );
                          }
                        },
                  text: l10n.registerSubmit,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

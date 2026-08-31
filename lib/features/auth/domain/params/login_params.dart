import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_params.freezed.dart';

/// Domain equivalent of [LoginRequest].
@freezed
sealed class LoginParams with _$LoginParams {
  const factory LoginParams({
    required String email,
    required String password,
  }) = _LoginParams;
}

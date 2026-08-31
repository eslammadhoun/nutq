import 'package:freezed_annotation/freezed_annotation.dart';

part 'register_params.freezed.dart';

/// Domain equivalent of [RegisterRequest].
@freezed
sealed class RegisterParams with _$RegisterParams {
  const factory RegisterParams({
    required String name,
    required String email,
    required String password,
  }) = _RegisterParams;
}

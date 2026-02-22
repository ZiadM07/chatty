import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sign_up_model.g.dart';

@JsonSerializable()
class SignUpModel extends Equatable {
  final String email;
  final String password;
  final String confirmPassword;

  const SignUpModel({
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
  });

  factory SignUpModel.fromJson(Map<String, dynamic> json) =>
      _$SignUpModelFromJson(json);

  Map<String, dynamic> toJson() => _$SignUpModelToJson(this);

  SignUpModel copyWith({
    String? email,
    String? password,
    String? confirmPassword,
  }) {
    return SignUpModel(
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
    );
  }

  String? get emailError {
    if (email.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) return 'Enter a valid email address';
    return null;
  }

  String? get passwordError {
    if (password.isEmpty) return 'Password is required';
    if (password.length < 8) return 'Password must be at least 8 characters';
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  String? get confirmPasswordError {
    if (confirmPassword.isEmpty) return 'Please confirm your password';
    if (confirmPassword != password) return 'Passwords do not match';
    return null;
  }

  bool get isValid =>
      emailError == null &&
      passwordError == null &&
      confirmPasswordError == null;

  @override
  List<Object?> get props => [email, password, confirmPassword];

  @override
  String toString() => 'SignUpModel(email: $email)';
}

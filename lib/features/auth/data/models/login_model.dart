import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'login_model.g.dart';

@JsonSerializable()
class LoginModel extends Equatable {
  final String email;
  final String password;
  final bool rememberMe;

  const LoginModel({
    this.email = '',
    this.password = '',
    this.rememberMe = false,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) =>
      _$LoginModelFromJson(json);

  Map<String, dynamic> toJson() => _$LoginModelToJson(this);

  LoginModel copyWith({String? email, String? password, bool? rememberMe}) {
    return LoginModel(
      email: email ?? this.email,
      password: password ?? this.password,
      rememberMe: rememberMe ?? this.rememberMe,
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
    return null;
  }

  bool get isValid => emailError == null && passwordError == null;

  @override
  List<Object?> get props => [email, password, rememberMe];

  @override
  String toString() => 'LoginModel(email: $email, rememberMe: $rememberMe)';
}

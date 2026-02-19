import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'auth_model.g.dart';

@JsonSerializable()
class AuthModel extends Equatable {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? phoneNumber;
  final bool emailVerified;
  final bool isProfileComplete;
  final DateTime? createdAt;
  final DateTime? lastSignInAt;

  const AuthModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.phoneNumber,
    this.emailVerified = false,
    this.isProfileComplete = false,
    this.createdAt,
    this.lastSignInAt,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) =>
      _$AuthModelFromJson(json);

  factory AuthModel.fromFirebaseUser(Map<String, dynamic> firebaseUser) {
    return AuthModel(
      uid: firebaseUser['uid'] as String,
      email: firebaseUser['email'] as String? ?? '',
      displayName: firebaseUser['displayName'] as String?,
      photoUrl: firebaseUser['photoURL'] as String?,
      phoneNumber: firebaseUser['phoneNumber'] as String?,
      emailVerified: firebaseUser['emailVerified'] as bool? ?? false,
      isProfileComplete: firebaseUser['isProfileComplete'] as bool? ?? false,
      createdAt: firebaseUser['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              firebaseUser['createdAt'] as int,
            )
          : null,
      lastSignInAt: firebaseUser['lastSignInAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              firebaseUser['lastSignInAt'] as int,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => _$AuthModelToJson(this);

  AuthModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    bool? emailVerified,
    bool? isProfileComplete,
    DateTime? createdAt,
    DateTime? lastSignInAt,
  }) {
    return AuthModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      emailVerified: emailVerified ?? this.emailVerified,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      createdAt: createdAt ?? this.createdAt,
      lastSignInAt: lastSignInAt ?? this.lastSignInAt,
    );
  }

  /// Returns true if the user needs to be redirected to FillProfile screen.
  bool get needsProfileSetup => !isProfileComplete;

  /// Returns a display-friendly name, falling back to email prefix.
  String get name =>
      displayName?.isNotEmpty == true ? displayName! : email.split('@').first;

  @override
  List<Object?> get props => [
    uid,
    email,
    displayName,
    photoUrl,
    phoneNumber,
    emailVerified,
    isProfileComplete,
    createdAt,
    lastSignInAt,
  ];

  @override
  String toString() =>
      'AuthModel(uid: $uid, email: $email, isProfileComplete: $isProfileComplete)';
}

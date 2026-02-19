import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

enum UserStatus { online, offline, away }

enum Gender { male, female }

@JsonSerializable()
class UserModel extends Equatable {
  final String uid;
  final String email;
  final String username;
  final String fullName;
  final String? bio;
  final String? photoUrl;
  final String? phoneNumber;
  final Gender gender;
  final UserStatus status;
  final bool isOnline;
  final DateTime? lastSeen;
  final DateTime createdAt;
  final List<String> blockedUsers;

  const UserModel({
    required this.uid,
    required this.email,
    required this.username,
    required this.fullName,
    this.bio,
    this.photoUrl,
    this.phoneNumber,
    this.gender = Gender.male,
    this.status = UserStatus.offline,
    this.isOnline = false,
    this.lastSeen,
    required this.createdAt,
    this.blockedUsers = const [],
  });

  // ─── Factory: from JSON ───────────────────────────────────────────────────

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  // ─── Factory: from Firestore ──────────────────────────────────────────────

  factory UserModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] as String? ?? '',
      username: data['username'] as String? ?? '',
      fullName: data['fullName'] as String? ?? '',
      bio: data['bio'] as String?,
      photoUrl: data['photoUrl'] as String?,
      phoneNumber: data['phoneNumber'] as String?,
      gender: Gender.values.firstWhere(
        (e) => e.name == (data['gender'] as String? ?? 'male'),
        orElse: () => Gender.male,
      ),
      status: UserStatus.values.firstWhere(
        (e) => e.name == (data['status'] as String? ?? 'offline'),
        orElse: () => UserStatus.offline,
      ),
      isOnline: data['isOnline'] as bool? ?? false,
      lastSeen: data['lastSeen'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['lastSeen'] as int)
          : null,
      createdAt: data['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['createdAt'] as int)
          : DateTime.now(),
      blockedUsers: List<String>.from(data['blockedUsers'] as List? ?? []),
    );
  }

  // ─── To JSON ──────────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  // ─── To Firestore Map ─────────────────────────────────────────────────────

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'fullName': fullName,
      'bio': bio,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'gender': gender.name,
      'status': status.name,
      'isOnline': isOnline,
      'lastSeen': lastSeen?.millisecondsSinceEpoch,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'blockedUsers': blockedUsers,
    };
  }

  // ─── CopyWith ─────────────────────────────────────────────────────────────

  UserModel copyWith({
    String? uid,
    String? email,
    String? username,
    String? fullName,
    String? bio,
    String? photoUrl,
    String? phoneNumber,
    Gender? gender,
    UserStatus? status,
    bool? isOnline,
    DateTime? lastSeen,
    DateTime? createdAt,
    List<String>? blockedUsers,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      bio: bio ?? this.bio,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gender: gender ?? this.gender,
      status: status ?? this.status,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
      blockedUsers: blockedUsers ?? this.blockedUsers,
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  /// Display name fallback: fullName → username → email prefix
  String get displayName => fullName.isNotEmpty
      ? fullName
      : username.isNotEmpty
      ? username
      : email.split('@').first;

  bool get hasPhoto => photoUrl != null && photoUrl!.isNotEmpty;

  bool get hasBio => bio != null && bio!.isNotEmpty;

  bool isBlockedBy(String otherUid) => blockedUsers.contains(otherUid);

  // ─── Equatable ────────────────────────────────────────────────────────────

  @override
  List<Object?> get props => [
    uid,
    email,
    username,
    fullName,
    bio,
    photoUrl,
    phoneNumber,
    gender,
    status,
    isOnline,
    lastSeen,
    createdAt,
    blockedUsers,
  ];

  @override
  String toString() =>
      'UserModel(uid: $uid, username: $username, isOnline: $isOnline)';
}

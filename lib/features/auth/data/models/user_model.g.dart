// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  uid: json['uid'] as String,
  email: json['email'] as String,
  username: json['username'] as String,
  fullName: json['fullName'] as String,
  bio: json['bio'] as String?,
  photoUrl: json['photoUrl'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  gender: $enumDecodeNullable(_$GenderEnumMap, json['gender']) ?? Gender.male,
  status:
      $enumDecodeNullable(_$UserStatusEnumMap, json['status']) ??
      UserStatus.offline,
  isOnline: json['isOnline'] as bool? ?? false,
  lastSeen: json['lastSeen'] == null
      ? null
      : DateTime.parse(json['lastSeen'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  blockedUsers:
      (json['blockedUsers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'uid': instance.uid,
  'email': instance.email,
  'username': instance.username,
  'fullName': instance.fullName,
  'bio': instance.bio,
  'photoUrl': instance.photoUrl,
  'phoneNumber': instance.phoneNumber,
  'gender': _$GenderEnumMap[instance.gender]!,
  'status': _$UserStatusEnumMap[instance.status]!,
  'isOnline': instance.isOnline,
  'lastSeen': instance.lastSeen?.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'blockedUsers': instance.blockedUsers,
};

const _$GenderEnumMap = {Gender.male: 'male', Gender.female: 'female'};

const _$UserStatusEnumMap = {
  UserStatus.online: 'online',
  UserStatus.offline: 'offline',
  UserStatus.away: 'away',
};

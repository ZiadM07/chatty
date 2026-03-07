import 'package:Chatty/core/constants/exports.dart';
import 'package:Chatty/core/utils/enums.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel extends Equatable {
  final String id;
  final ChatType type;
  final List<String> memberIds;
  final Map<String, String> memberNames;
  final String? groupName;
  final String? groupPhotoUrl;
  final String? groupCreatedBy;
  final String? groupDescription;
  final String? lastMessage;
  final MessageType? lastMessageType;
  final String? lastMessageSenderId;
  final DateTime? lastMessageAt;
  final Map<String, int> unreadCounts;
  final DateTime createdAt;

  const ChatModel({
    required this.id,
    required this.type,
    required this.memberIds,
    this.memberNames = const {},
    this.groupName,
    this.groupPhotoUrl,
    this.groupCreatedBy,
    this.groupDescription,
    this.lastMessage,
    this.lastMessageType,
    this.lastMessageSenderId,
    this.lastMessageAt,
    this.unreadCounts = const {},
    required this.createdAt,
  });

  factory ChatModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ChatModel(
      id: id,
      type: ChatType.values.firstWhere(
        (e) => e.name == (data['type'] as String?),
        orElse: () => ChatType.oneToOne,
      ),
      memberIds: List<String>.from(data['memberIds'] as List? ?? []),
      memberNames: Map<String, String>.from(data['memberNames'] as Map? ?? {}),
      groupName: data['groupName'] as String?,
      groupPhotoUrl: data['groupPhotoUrl'] as String?,
      groupCreatedBy: data['groupCreatedBy'] as String?,
      groupDescription: data['groupDescription'] as String?,
      lastMessage: data['lastMessage'] as String?,
      lastMessageType: data['lastMessageType'] != null
          ? MessageType.values.firstWhere(
              (e) => e.name == data['lastMessageType'],
              orElse: () => MessageType.text,
            )
          : null,
      lastMessageSenderId: data['lastMessageSenderId'] as String?,
      lastMessageAt: (data['lastMessageAt'] as Timestamp?)?.toDate(),
      unreadCounts: Map<String, int>.from(data['unreadCounts'] as Map? ?? {}),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'type': type.name,
    'memberIds': memberIds,
    'memberNames': memberNames,
    'groupName': groupName,
    'groupPhotoUrl': groupPhotoUrl,
    'groupCreatedBy': groupCreatedBy,
    'groupDescription': groupDescription,
    'lastMessage': lastMessage,
    'lastMessageType': lastMessageType?.name,
    'lastMessageSenderId': lastMessageSenderId,
    'lastMessageAt': lastMessageAt != null
        ? Timestamp.fromDate(lastMessageAt!)
        : null,
    'unreadCounts': unreadCounts,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  ChatModel copyWith({
    String? id,
    ChatType? type,
    List<String>? memberIds,
    Map<String, String>? memberNames,
    String? groupName,
    String? groupPhotoUrl,
    String? groupCreatedBy,
    String? groupDescription,
    String? lastMessage,
    MessageType? lastMessageType,
    String? lastMessageSenderId,
    DateTime? lastMessageAt,
    Map<String, int>? unreadCounts,
    DateTime? createdAt,
  }) => ChatModel(
    id: id ?? this.id,
    type: type ?? this.type,
    memberIds: memberIds ?? this.memberIds,
    memberNames: memberNames ?? this.memberNames,
    groupName: groupName ?? this.groupName,
    groupPhotoUrl: groupPhotoUrl ?? this.groupPhotoUrl,
    groupCreatedBy: groupCreatedBy ?? this.groupCreatedBy,
    groupDescription: groupDescription ?? this.groupDescription,
    lastMessage: lastMessage ?? this.lastMessage,
    lastMessageType: lastMessageType ?? this.lastMessageType,
    lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
    lastMessageAt: lastMessageAt ?? this.lastMessageAt,
    unreadCounts: unreadCounts ?? this.unreadCounts,
    createdAt: createdAt ?? this.createdAt,
  );

  bool get isGroup => type == ChatType.group;
  bool get isOneToOne => type == ChatType.oneToOne;
  String otherMemberId(String uid) =>
      memberIds.firstWhere((id) => id != uid, orElse: () => '');
  String nameFor(String uid) => memberNames[uid] ?? uid;
  int unreadCountFor(String uid) => unreadCounts[uid] ?? 0;

  @override
  List<Object?> get props => [
    id,
    type,
    memberIds,
    memberNames,
    groupName,
    groupPhotoUrl,
    groupCreatedBy,
    groupDescription,
    lastMessage,
    lastMessageType,
    lastMessageSenderId,
    lastMessageAt,
    unreadCounts,
    createdAt,
  ];
}

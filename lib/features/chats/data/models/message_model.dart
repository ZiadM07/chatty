import 'package:Chatty/core/constants/exports.dart';
import 'package:Chatty/core/utils/enums.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel extends Equatable {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final MessageType type;
  final MessageStatus status;
  final DateTime createdAt;
  final bool isDeleted;
  final List<String> readBy;
  final String? replyToId;
  final String? replyToContent;
  final String? replyToSenderId;
  final MessageType? replyToType;
  final Map<String, dynamic>? metadata;
  final Map<String, String> reactions;
  const MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    this.type = MessageType.text,
    this.status = MessageStatus.sending,
    required this.createdAt,
    this.isDeleted = false,
    this.readBy = const [],
    this.replyToId,
    this.replyToContent,
    this.replyToSenderId,
    this.replyToType,
    this.metadata,
    this.reactions = const {},
  });

  factory MessageModel.fromFirestore(
    Map<String, dynamic> data,
    String id,
    String chatId,
  ) {
    MessageType? parseReplyToType(String? raw) {
      if (raw == null) return null;
      for (final v in MessageType.values) {
        if (v.name == raw) return v;
      }
      return null;
    }

    return MessageModel(
      id: id,
      chatId: chatId,
      senderId: data['senderId'] as String? ?? '',
      content: data['content'] as String? ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.name == (data['type'] as String?),
        orElse: () => MessageType.text,
      ),
      status: MessageStatus.values.firstWhere(
        (e) => e.name == (data['status'] as String?),
        orElse: () => MessageStatus.sent,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isDeleted: data['isDeleted'] as bool? ?? false,
      readBy: List<String>.from(data['readBy'] as List? ?? []),
      replyToId: data['replyToId'] as String?,
      replyToContent: data['replyToContent'] as String?,
      replyToSenderId: data['replyToSenderId'] as String?,
      replyToType: parseReplyToType(data['replyToType'] as String?),
      metadata: data['metadata'] as Map<String, dynamic>?,
      reactions: Map<String, String>.from(data['reactions'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'senderId': senderId,
    'content': content,
    'type': type.name,
    'status': status.name,
    'createdAt': Timestamp.fromDate(createdAt),
    'isDeleted': isDeleted,
    'readBy': readBy,
    'replyToId': replyToId,
    'replyToContent': replyToContent,
    'replyToSenderId': replyToSenderId,
    'replyToType': replyToType?.name,
    if (metadata != null) 'metadata': metadata,
    'reactions': reactions,
  };

  MessageModel copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? content,
    MessageType? type,
    MessageStatus? status,
    DateTime? createdAt,
    bool? isDeleted,
    List<String>? readBy,
    String? replyToId,
    String? replyToContent,
    String? replyToSenderId,
    MessageType? replyToType,
    Map<String, dynamic>? metadata,
    Map<String, String>? reactions,
  }) => MessageModel(
    id: id ?? this.id,
    chatId: chatId ?? this.chatId,
    senderId: senderId ?? this.senderId,
    content: content ?? this.content,
    type: type ?? this.type,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    isDeleted: isDeleted ?? this.isDeleted,
    readBy: readBy ?? this.readBy,
    replyToId: replyToId ?? this.replyToId,
    replyToContent: replyToContent ?? this.replyToContent,
    replyToSenderId: replyToSenderId ?? this.replyToSenderId,
    replyToType: replyToType ?? this.replyToType,
    metadata: metadata ?? this.metadata,
    reactions: reactions ?? this.reactions,
  );

  bool get isMedia => type != MessageType.text;
  bool isReadBy(String uid) => readBy.contains(uid);

  @override
  List<Object?> get props => [
    id,
    chatId,
    senderId,
    content,
    type,
    status,
    createdAt,
    isDeleted,
    readBy,
    replyToId,
    replyToContent,
    replyToSenderId,
    replyToType,
    reactions,
  ];
}

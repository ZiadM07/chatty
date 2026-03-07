enum Gender { male, female }

enum ChatType { oneToOne, group }

enum MessageType { text, image, audio, video, file, deleted }

enum MessageStatus { sending, sent, delivered, read, failed }

enum UserStatus { online, offline, away }

enum StoryItemType { image, video, text }

enum NotificationType {
  chatMessage,
  groupMessage,
  storyReply,
  communityMessage;

  String get key => switch (this) {
    chatMessage => 'chat_message',
    groupMessage => 'group_message',
    storyReply => 'story_reply',
    communityMessage => 'community_message',
  };

  static NotificationType fromKey(String key) {
    return switch (key) {
      'chat_message' => chatMessage,
      'group_message' => groupMessage,
      'story_reply' => storyReply,
      'community_message' => communityMessage,
      _ => chatMessage,
    };
  }
}

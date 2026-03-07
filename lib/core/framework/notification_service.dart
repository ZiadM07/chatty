import 'package:Chatty/core/constants/app_endpoints.dart';
import 'package:Chatty/core/constants/exports.dart';
import 'package:Chatty/core/di/injectable.dart';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:Chatty/config/router/app_router.gr.dart';

@singleton
class NotificationService {
  final AppPreferences prefs;
  NotificationService(this.prefs);

  Future<void> initialize() async {
    await OneSignal.Notifications.requestPermission(true);

    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      event.preventDefault();

      final router = getIt<AppRouter>();
      final routeName = router.current.name;
      final isChatOpen = routeName == ChatRoute.name;

      if (!isChatOpen) {
        OneSignal.Notifications.displayNotification(
          event.notification.notificationId,
        );
      }
    });

    OneSignal.Notifications.addClickListener((event) {
      _handleNotification(event.notification);
    });
  }

  Future<void> login(String uid) async {
    await OneSignal.login(uid);
  }

  Future<void> logout() async {
    await OneSignal.logout();
  }

  void _handleNotification(OSNotification notification) {
    final data = notification.additionalData;
    if (data == null) return;

    final router = getIt<AppRouter>();

    switch (data['type']) {
      case 'message':
      case 'group_message':
        router.push(ChatRoute(chatId: data['chatId']));
        break;
    }
  }

  Future<void> sendMessageNotification({
    required String senderUid,
    required String senderUsername,
    required String receiverUid,
    required String message,
    required String chatId,
  }) async {
    if (!prefs.messageNotifications) return;
    if (prefs.isChatMuted(chatId)) return;

    final preview = prefs.preview ? message : 'New message';

    final payload = {
      'app_id': AppEndpoints.oneSignalAppId,
      'include_external_user_ids': [receiverUid],
      'headings': {'en': senderUsername},
      'contents': {'en': preview},
      'priority': 10,
      'android_priority': 2,
      'android_channel_id': AppEndpoints.oneSignalChannelId,
      'android_sound': prefs.sound ? 'default' : null,
      'ios_sound': prefs.sound ? 'default' : null,
      'android_vibration_pattern': prefs.vibration ? [100, 200, 100] : null,
      'android_visibility': 1,
      'mutable_content': true,
      'ttl': 14400,
      'data': {
        'type': 'message',
        'chatId': chatId,
        'senderUsername': senderUsername,
      },
    };

    await _postNotification(payload);
  }

  Future<void> sendGroupNotification({
    required String senderUsername,
    required List<String> recipientUids,
    required String message,
    required String chatId,
    required String groupName,
    String? groupPhoto,
  }) async {
    if (!prefs.groupNotifications) return;
    if (prefs.isChatMuted(chatId)) return;

    final preview = prefs.preview
        ? '$senderUsername: $message'
        : '$senderUsername sent a message';

    final payload = {
      'app_id': AppEndpoints.oneSignalAppId,
      'include_external_user_ids': recipientUids,
      'headings': {'en': groupName},
      'contents': {'en': preview},
      'priority': 10,
      'android_priority': 2,
      'android_channel_id': AppEndpoints.oneSignalChannelId,
      'android_sound': prefs.sound ? 'default' : null,
      'ios_sound': prefs.sound ? 'default' : null,
      'android_vibration_pattern': prefs.vibration ? [100, 200, 100] : null,
      'android_visibility': 1,
      'mutable_content': true,
      'ttl': 14400,
      'data': {
        'type': 'group_message',
        'chatId': chatId,
        'senderUsername': senderUsername,
      },
    };

    await _postNotification(payload);
  }

  Future<void> _postNotification(Map<String, dynamic> payload) async {
    debugPrint('📤 Targeting UIDs: ${payload['include_external_user_ids']}');
    debugPrint('📤 Full payload: ${jsonEncode(payload)}');

    final res = await http.post(
      Uri.parse('https://onesignal.com/api/v1/notifications'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Basic ${AppEndpoints.oneSignalRestApiKey}',
      },
      body: jsonEncode(payload),
    );

    debugPrint('📬 Status: ${res.statusCode}');
    debugPrint('📬 Response: ${res.body}');
  }
}

// notifications_cubit.dart
import 'package:Chatty/core/framework/notification_service.dart';
import '../../../core/constants/exports.dart';

@singleton
class NotificationsCubit extends Cubit<AppState<NotificationSettings>> {
  final AppPreferences _prefs;
  final NotificationService _notificationService;

  NotificationsCubit(this._prefs, this._notificationService)
    : super(const AppState()) {
    loadSettings();
  }

  NotificationSettings get settings => state.data ?? _settingsFromPrefs();

  void loadSettings() {
    emit(AppState(status: StateStatus.success, data: _settingsFromPrefs()));
  }

  void toggleMessageNotifications(bool value) {
    _prefs.messageNotifications = value;
    _emitUpdated((s) => s.copyWith(messageNotifications: value));
  }

  void toggleGroupNotifications(bool value) {
    _prefs.groupNotifications = value;
    _emitUpdated((s) => s.copyWith(groupNotifications: value));
  }

  void toggleStoryReplyNotifications(bool value) {
    _prefs.storyReplyNotifications = value;
    _emitUpdated((s) => s.copyWith(storyReplyNotifications: value));
  }

  void toggleSound(bool value) {
    _prefs.sound = value;
    _emitUpdated((s) => s.copyWith(sound: value));
  }

  void toggleVibration(bool value) {
    _prefs.vibration = value;
    _emitUpdated((s) => s.copyWith(vibration: value));
  }

  void togglePreview(bool value) {
    _prefs.preview = value;
    _emitUpdated((s) => s.copyWith(preview: value));
  }

  void toggleInAppSound(bool value) {
    _prefs.inAppSound = value;
    _emitUpdated((s) => s.copyWith(inAppSound: value));
  }

  Future<void> loginToNotifications(String uid) async {
    try {
      emit(state.copyWith(status: StateStatus.loadingOverlay));
      await _notificationService.login(uid);
      emit(state.copyWith(status: StateStatus.success));
    } catch (e) {
      emit(state.copyWith(status: StateStatus.error, message: e.toString()));
    }
  }

  Future<void> logoutFromNotifications() async {
    try {
      emit(state.copyWith(status: StateStatus.loadingOverlay));
      await _notificationService.logout();
      emit(state.copyWith(status: StateStatus.success));
    } catch (e) {
      emit(state.copyWith(status: StateStatus.error, message: e.toString()));
    }
  }

  NotificationSettings _settingsFromPrefs() => NotificationSettings(
    messageNotifications: _prefs.messageNotifications,
    groupNotifications: _prefs.groupNotifications,
    storyReplyNotifications: _prefs.storyReplyNotifications,
    sound: _prefs.sound,
    vibration: _prefs.vibration,
    preview: _prefs.preview,
    inAppSound: _prefs.inAppSound,
  );

  void _emitUpdated(
    NotificationSettings Function(NotificationSettings) update,
  ) {
    emit(
      AppState(
        status: StateStatus.success,
        data: update(state.data ?? _settingsFromPrefs()),
      ),
    );
  }
}

class NotificationSettings extends Equatable {
  final bool messageNotifications;
  final bool groupNotifications;
  final bool storyReplyNotifications;
  final bool sound;
  final bool vibration;
  final bool preview;
  final bool inAppSound;

  const NotificationSettings({
    required this.messageNotifications,
    required this.groupNotifications,
    required this.storyReplyNotifications,
    required this.sound,
    required this.vibration,
    required this.preview,
    required this.inAppSound,
  });

  NotificationSettings copyWith({
    bool? messageNotifications,
    bool? groupNotifications,
    bool? storyReplyNotifications,
    bool? sound,
    bool? vibration,
    bool? preview,
    bool? inAppSound,
  }) {
    return NotificationSettings(
      messageNotifications: messageNotifications ?? this.messageNotifications,
      groupNotifications: groupNotifications ?? this.groupNotifications,
      storyReplyNotifications:
          storyReplyNotifications ?? this.storyReplyNotifications,
      sound: sound ?? this.sound,
      vibration: vibration ?? this.vibration,
      preview: preview ?? this.preview,
      inAppSound: inAppSound ?? this.inAppSound,
    );
  }

  @override
  List<Object?> get props => [
    messageNotifications,
    groupNotifications,
    storyReplyNotifications,
    sound,
    vibration,
    preview,
    inAppSound,
  ];
}

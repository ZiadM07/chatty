// in_app_sound_service.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:Chatty/core/constants/exports.dart';
import 'package:Chatty/core/di/injectable.dart';
import 'package:Chatty/features/profile/cubits/notifications_cubit.dart';

@singleton
class InAppSoundService {
  final AudioPlayer _player = AudioPlayer();

  NotificationsCubit get _cubit => getIt<NotificationsCubit>();

  Future<void> playMessageSound() async {
    if (!_cubit.settings.inAppSound) return;
    await _play('sounds/message.mp3');
  }

  Future<void> playStoryReplySound() async {
    if (!_cubit.settings.inAppSound) return;
    await _play('sounds/message.mp3');
  }

  Future<void> _play(String asset) async {
    try {
      await _player.stop();
      await _player.play(AssetSource(asset));
    } catch (e) {
      debugPrint('🔇 InAppSoundService: $e');
    }
  }

  void dispose() => _player.dispose();
}

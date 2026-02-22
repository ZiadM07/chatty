import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  AudioService
// ─────────────────────────────────────────────────────────────────────────────
//
//  Enhanced singleton service with:
//  - Recording with amplitude monitoring (for visual feedback)
//  - Playback with detailed state management
//  - Automatic resource cleanup
//  - One active player at a time (global playback control)
// ─────────────────────────────────────────────────────────────────────────────

@singleton
class AudioService {
  final AudioRecorder _recorder = AudioRecorder();
  AudioPlayer? _activePlayer;
  String? _currentlyPlayingUrl;
  Timer? _amplitudeTimer;

  final _recordingStateController =
      StreamController<RecordingState>.broadcast();
  final _playbackStateController = StreamController<PlaybackState>.broadcast();

  Stream<RecordingState> get recordingState => _recordingStateController.stream;
  Stream<PlaybackState> get playbackState => _playbackStateController.stream;

  // ═══════════════════════════════════════════════════════════════════════════
  // RECORDING
  // ═══════════════════════════════════════════════════════════════════════════

  /// Check if recording permission is granted.
  Future<bool> hasRecordPermission() async {
    return _recorder.hasPermission();
  }

  /// Start recording with amplitude monitoring for visual feedback.
  Future<RecordingResult> startRecording() async {
    try {
      if (!await hasRecordPermission()) {
        throw AudioException('Microphone permission denied');
      }

      // Stop any active playback before recording
      await stopPlayback();

      final tempDir = await getTemporaryDirectory();
      final fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final path = '${tempDir.path}/$fileName';

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );

      final startTime = DateTime.now();

      // Monitor amplitude and duration during recording
      _amplitudeTimer?.cancel();
      _amplitudeTimer = Timer.periodic(const Duration(milliseconds: 100), (
        timer,
      ) async {
        if (!await _recorder.isRecording()) {
          timer.cancel();
          return;
        }

        final amplitude = await _recorder.getAmplitude();
        final duration = DateTime.now().difference(startTime);

        _recordingStateController.add(
          RecordingState(
            isRecording: true,
            duration: duration,
            amplitude: amplitude.current.clamp(-160.0, 0.0), // dB range
            path: path,
          ),
        );
      });

      return RecordingResult.success(path);
    } catch (e) {
      return RecordingResult.error(e.toString());
    }
  }

  /// Stop recording and return the file + duration.
  Future<RecordingResult> stopRecording() async {
    try {
      _amplitudeTimer?.cancel();

      final path = await _recorder.stop();
      if (path == null) {
        return RecordingResult.error('Recording failed');
      }

      final file = File(path);
      if (!file.existsSync()) {
        return RecordingResult.error('Recording file not found');
      }

      // Get duration by creating a temporary player
      final tempPlayer = AudioPlayer();
      Duration duration = Duration.zero;

      try {
        await tempPlayer.setSourceDeviceFile(path);
        duration = await tempPlayer.getDuration() ?? Duration.zero;
      } finally {
        await tempPlayer.dispose();
      }

      _recordingStateController.add(RecordingState.idle());

      return RecordingResult.success(path, file: file, duration: duration);
    } catch (e) {
      return RecordingResult.error(e.toString());
    }
  }

  /// Cancel recording without saving.
  Future<void> cancelRecording() async {
    try {
      _amplitudeTimer?.cancel();
      final path = await _recorder.stop();
      if (path != null) {
        final file = File(path);
        if (file.existsSync()) await file.delete();
      }
      _recordingStateController.add(RecordingState.idle());
    } catch (_) {}
  }

  /// Check if currently recording.
  Future<bool> isRecording() => _recorder.isRecording();

  // ═══════════════════════════════════════════════════════════════════════════
  // PLAYBACK
  // ═══════════════════════════════════════════════════════════════════════════

  /// Play audio from URL or file path. Stops any currently playing audio.
  Future<void> play(String source) async {
    try {
      // Stop previous player if playing different source
      if (_currentlyPlayingUrl != source) {
        await stopPlayback();
      } else if (_activePlayer != null) {
        // Same source — resume if paused
        await resume();
        return;
      }

      _activePlayer = AudioPlayer();
      _currentlyPlayingUrl = source;

      // Set source (URL or file)
      if (source.startsWith('http')) {
        await _activePlayer!.setSourceUrl(source);
      } else {
        await _activePlayer!.setSourceDeviceFile(source);
      }

      final duration = await _activePlayer!.getDuration() ?? Duration.zero;

      // Listen to position changes
      _activePlayer!.onPositionChanged.listen((position) {
        _playbackStateController.add(
          PlaybackState(
            url: source,
            isPlaying: true,
            position: position,
            duration: duration,
          ),
        );
      });

      // Listen to state changes (completion, errors)
      _activePlayer!.onPlayerStateChanged.listen((state) {
        if (state == PlayerState.completed) {
          _playbackStateController.add(
            PlaybackState(
              url: source,
              isPlaying: false,
              position: Duration.zero,
              duration: duration,
            ),
          );
          stopPlayback();
        }
      });

      await _activePlayer!.resume();
    } catch (e) {
      _playbackStateController.add(PlaybackState.error(source, e.toString()));
    }
  }

  /// Resume playback if paused.
  Future<void> resume() async {
    await _activePlayer?.resume();
  }

  /// Pause playback.
  Future<void> pause() async {
    await _activePlayer?.pause();
  }

  /// Seek to a specific position.
  Future<void> seek(Duration position) async {
    await _activePlayer?.seek(position);
  }

  /// Stop and dispose current player.
  Future<void> stopPlayback() async {
    await _activePlayer?.stop();
    await _activePlayer?.dispose();
    _activePlayer = null;
    _currentlyPlayingUrl = null;
  }

  /// Check if a specific URL is currently playing.
  bool isPlaying(String url) =>
      _currentlyPlayingUrl == url &&
      _activePlayer?.state == PlayerState.playing;

  /// Get current playing URL.
  String? get currentlyPlayingUrl => _currentlyPlayingUrl;

  // ═══════════════════════════════════════════════════════════════════════════
  // CLEANUP
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> dispose() async {
    _amplitudeTimer?.cancel();
    await _recorder.dispose();
    await stopPlayback();
    await _recordingStateController.close();
    await _playbackStateController.close();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Models
// ─────────────────────────────────────────────────────────────────────────────

@immutable
class RecordingState {
  final bool isRecording;
  final Duration duration;
  final double amplitude; // dB value: -160 (silence) to 0 (loud)
  final String? path;
  final String? error;

  const RecordingState({
    required this.isRecording,
    required this.duration,
    required this.amplitude,
    this.path,
    this.error,
  });

  const RecordingState.idle()
    : isRecording = false,
      duration = Duration.zero,
      amplitude = -160,
      path = null,
      error = null;

  /// Normalized amplitude 0.0 (silence) to 1.0 (loud)
  double get normalizedAmplitude => ((amplitude + 160) / 160).clamp(0.0, 1.0);
}

@immutable
class RecordingResult {
  final bool success;
  final String? path;
  final File? file;
  final Duration duration;
  final String? error;

  const RecordingResult({
    required this.success,
    this.path,
    this.file,
    required this.duration,
    this.error,
  });

  const RecordingResult.success(
    this.path, {
    this.file,
    this.duration = Duration.zero,
  }) : success = true,
       error = null;

  const RecordingResult.error(this.error)
    : success = false,
      path = null,
      file = null,
      duration = Duration.zero;
}

@immutable
class PlaybackState {
  final String url;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final String? error;

  const PlaybackState({
    required this.url,
    required this.isPlaying,
    required this.position,
    required this.duration,
    this.error,
  });

  const PlaybackState.error(this.url, this.error)
    : isPlaying = false,
      position = Duration.zero,
      duration = Duration.zero;

  double get progress => duration.inMilliseconds > 0
      ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
      : 0.0;

  Duration get remaining => duration - position;
}

class AudioException implements Exception {
  final String message;
  const AudioException(this.message);
  @override
  String toString() => 'AudioException: $message';
}

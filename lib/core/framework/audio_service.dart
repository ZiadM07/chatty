import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class RecordingResult {
  final File? file;
  final Duration duration;
  const RecordingResult({this.file, this.duration = Duration.zero});
}

class AudioPlaybackState {
  final String? activeUrl;
  final bool isPlaying;
  final Duration position;
  final Duration duration;

  const AudioPlaybackState({
    this.activeUrl,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
  });

  bool get isIdle => activeUrl == null;

  AudioPlaybackState copyWith({
    String? activeUrl,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
  }) => AudioPlaybackState(
    activeUrl: activeUrl ?? this.activeUrl,
    isPlaying: isPlaying ?? this.isPlaying,
    position: position ?? this.position,
    duration: duration ?? this.duration,
  );
}

@lazySingleton
class AudioService {
  AudioService();

  final _player = AudioPlayer();
  String? _activeUrl;

  final _stateController = StreamController<AudioPlaybackState>.broadcast();
  StreamSubscription<void>? _completeSub;
  StreamSubscription<PlayerState>? _stateSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration>? _durationSub;

  AudioPlaybackState _current = const AudioPlaybackState();

  final _recorder = AudioRecorder();
  DateTime? _recordingStart;

  Stream<AudioPlaybackState> get playbackState => _stateController.stream;
  AudioPlaybackState get currentState => _current;

  Future<void> play(String url) async {
    if (_activeUrl == url &&
        _current.isPlaying == false &&
        _current.position > Duration.zero) {
      await _player.resume();
      return;
    }

    await _stopInternal();

    _activeUrl = url;
    _emit(
      _current.copyWith(
        activeUrl: url,
        isPlaying: true,
        position: Duration.zero,
        duration: Duration.zero,
      ),
    );

    _subscribeToPlayer();
    await _player.play(UrlSource(url));
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> resume() async {
    if (_activeUrl != null) await _player.resume();
  }

  Future<void> stop() async {
    await _stopInternal();
    _activeUrl = null;
    _emit(const AudioPlaybackState());
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
    _emit(_current.copyWith(position: position));
  }

  Future<bool> hasRecordPermission() async {
    final status = await Permission.microphone.status;
    if (status.isGranted) return true;
    return (await Permission.microphone.request()).isGranted;
  }

  Future<void> startRecording() async {
    if (_current.isPlaying) await _player.pause();

    final dir = await getTemporaryDirectory();
    final ts = DateTime.now().millisecondsSinceEpoch;
    final path = '${dir.path}/voice_$ts.m4a';
    _recordingStart = DateTime.now();

    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 128000),
      path: path,
    );
  }

  Future<RecordingResult> stopRecording() async {
    if (!await _recorder.isRecording()) return const RecordingResult();

    final path = await _recorder.stop();
    final duration = _recordingStart != null
        ? DateTime.now().difference(_recordingStart!)
        : Duration.zero;
    _recordingStart = null;

    if (path == null) return const RecordingResult();
    final file = File(path);
    if (!await file.exists()) return const RecordingResult();

    return RecordingResult(file: file, duration: duration);
  }

  Future<void> cancelRecording() async {
    if (await _recorder.isRecording()) await _recorder.cancel();
    _recordingStart = null;
  }

  void _subscribeToPlayer() {
    _cancelSubscriptions();

    _stateSub = _player.onPlayerStateChanged.listen((state) {
      final playing = state == PlayerState.playing;
      _emit(_current.copyWith(isPlaying: playing));
    });

    _positionSub = _player.onPositionChanged.listen((pos) {
      _emit(_current.copyWith(position: pos));
    });

    _durationSub = _player.onDurationChanged.listen((dur) {
      if (dur > Duration.zero) _emit(_current.copyWith(duration: dur));
    });

    _completeSub = _player.onPlayerComplete.listen((_) {
      _emit(_current.copyWith(isPlaying: false, position: _current.duration));
    });
  }

  Future<void> _stopInternal() async {
    _cancelSubscriptions();
    await _player.stop();
  }

  void _cancelSubscriptions() {
    _stateSub?.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();
    _completeSub?.cancel();
    _stateSub = null;
    _positionSub = null;
    _durationSub = null;
    _completeSub = null;
  }

  void _emit(AudioPlaybackState state) {
    _current = state;
    if (!_stateController.isClosed) _stateController.add(state);
  }

  Future<void> dispose() async {
    _cancelSubscriptions();
    await _player.dispose();
    await _recorder.dispose();
    await _stateController.close();
  }
}

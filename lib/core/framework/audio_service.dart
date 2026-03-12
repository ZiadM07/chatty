import 'dart:async';
import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class RecordingResult {
  final File? file;
  final Duration duration;
  final List<double> waveform;

  const RecordingResult({
    this.file,
    this.duration = Duration.zero,
    this.waveform = const [],
  });
}

class AudioPlaybackState {
  final String? activeUrl;
  final bool isPlaying;
  final bool isBuffering;
  final Duration position;
  final Duration duration;

  const AudioPlaybackState({
    this.activeUrl,
    this.isPlaying = false,
    this.isBuffering = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
  });

  bool get isIdle => activeUrl == null;

  AudioPlaybackState copyWith({
    String? activeUrl,
    bool? isPlaying,
    bool? isBuffering,
    Duration? position,
    Duration? duration,
  }) => AudioPlaybackState(
    activeUrl: activeUrl ?? this.activeUrl,
    isPlaying: isPlaying ?? this.isPlaying,
    isBuffering: isBuffering ?? this.isBuffering,
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
  StreamSubscription<PlayerState>? _playerStateSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;

  AudioPlaybackState _current = const AudioPlaybackState();

  final _recorder = AudioRecorder();
  DateTime? _recordingStart;

  Timer? _amplitudeTimer;
  final List<double> _amplitudeSamples = [];

  Stream<AudioPlaybackState> get playbackState => _stateController.stream;
  AudioPlaybackState get currentState => _current;

  Future<void> play(String url) async {
    if (_activeUrl == url &&
        !_current.isPlaying &&
        _current.position > Duration.zero &&
        _player.processingState != ProcessingState.completed) {
      await _player.play();
      return;
    }

    await _stopInternal();

    _activeUrl = url;
    _emit(
      _current.copyWith(
        activeUrl: url,
        isPlaying: true,
        isBuffering: true,
        position: Duration.zero,
        duration: Duration.zero,
      ),
    );

    _subscribeToPlayer();

    await _player.setUrl(url);
    await _player.play();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> resume() async {
    if (_activeUrl != null) await _player.play();
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
    _amplitudeSamples.clear();

    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 128000),
      path: path,
    );

    _amplitudeTimer = Timer.periodic(const Duration(milliseconds: 100), (
      _,
    ) async {
      try {
        final amp = await _recorder.getAmplitude();
        const noiseFloor = -50.0;
        final db = amp.current.clamp(noiseFloor, 0.0);
        final normalized = ((db - noiseFloor) / (-noiseFloor)).clamp(0.0, 1.0);
        _amplitudeSamples.add(normalized);
      } catch (_) {}
    });
  }

  Future<RecordingResult> stopRecording() async {
    if (!await _recorder.isRecording()) return const RecordingResult();

    _amplitudeTimer?.cancel();
    _amplitudeTimer = null;

    final path = await _recorder.stop();
    final duration = _recordingStart != null
        ? DateTime.now().difference(_recordingStart!)
        : Duration.zero;
    _recordingStart = null;

    if (path == null) return const RecordingResult();
    final file = File(path);
    if (!await file.exists()) return const RecordingResult();

    final waveform = _buildWaveform(_amplitudeSamples);
    _amplitudeSamples.clear();

    return RecordingResult(file: file, duration: duration, waveform: waveform);
  }

  Future<void> cancelRecording() async {
    _amplitudeTimer?.cancel();
    _amplitudeTimer = null;
    _amplitudeSamples.clear();
    if (await _recorder.isRecording()) await _recorder.cancel();
    _recordingStart = null;
  }

  List<double> _buildWaveform(List<double> raw, {int barCount = 30}) {
    if (raw.isEmpty) return List.filled(barCount, 0.3);

    final result = <double>[];
    for (int i = 0; i < barCount; i++) {
      final start = (i / barCount * raw.length).floor();
      final end = ((i + 1) / barCount * raw.length).ceil().clamp(0, raw.length);
      if (start >= end) {
        result.add(0.15);
        continue;
      }
      final window = raw.sublist(start, end);
      final avg = window.reduce((a, b) => a + b) / window.length;
      result.add(avg.clamp(0.08, 1.0));
    }
    return result;
  }

  void _subscribeToPlayer() {
    _cancelSubscriptions();
    _playerStateSub = _player.playerStateStream.listen((state) {
      final isBuffering =
          state.processingState == ProcessingState.loading ||
          state.processingState == ProcessingState.buffering;

      if (state.processingState == ProcessingState.completed) {
        _emit(
          _current.copyWith(
            isPlaying: false,
            isBuffering: false,
            position: Duration.zero,
          ),
        );
        return;
      }

      _emit(
        _current.copyWith(isPlaying: state.playing, isBuffering: isBuffering),
      );
    });

    _positionSub = _player.positionStream.listen((pos) {
      _emit(_current.copyWith(position: pos));
    });

    _durationSub = _player.durationStream.listen((dur) {
      if (dur != null && dur > Duration.zero) {
        _emit(_current.copyWith(duration: dur));
      }
    });
  }

  Future<void> _stopInternal() async {
    _cancelSubscriptions();
    await _player.stop();
  }

  void _cancelSubscriptions() {
    _playerStateSub?.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();
    _playerStateSub = null;
    _positionSub = null;
    _durationSub = null;
  }

  void _emit(AudioPlaybackState state) {
    _current = state;
    if (!_stateController.isClosed) _stateController.add(state);
  }

  Future<void> dispose() async {
    _amplitudeTimer?.cancel();
    _cancelSubscriptions();
    await _player.dispose();
    await _recorder.dispose();
    await _stateController.close();
  }
}

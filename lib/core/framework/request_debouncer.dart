import 'dart:async';
import 'dart:ui';

class RequestDebouncer {
  static Timer? _timer;

  static void run(
    VoidCallback callback, {
    Duration duration = const Duration(milliseconds: 700),
  }) {
    _timer?.cancel();
    _timer = Timer(duration, callback);
  }

  static void cancel() {
    _timer?.cancel();
  }

  static bool get isActive => _timer?.isActive ?? false;
}

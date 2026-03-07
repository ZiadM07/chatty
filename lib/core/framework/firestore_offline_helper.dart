import 'dart:async';
import 'package:injectable/injectable.dart';
import 'network.dart';

@lazySingleton
class FirestoreOfflineHelper {
  final NetworkInfo _networkInfo;
  static const Duration _networkCheckTimeout = Duration(seconds: 3);

  FirestoreOfflineHelper(this._networkInfo);

  Future<bool> _checkConnection() async {
    try {
      return await _networkInfo.isConnected.timeout(
        _networkCheckTimeout,
        onTimeout: () => false,
      );
    } catch (e) {
      return false;
    }
  }

  Future<void> executeWrite({
    required Future<void> Function() operation,
  }) async {
    final hasConnection = await _checkConnection();

    if (hasConnection) {
      await operation();
    } else {
      operation();
    }
  }

  Future<T> executeWriteWithResult<T>({
    required Future<T> Function() operation,
    required T offlineResult,
  }) async {
    final hasConnection = await _checkConnection();

    if (hasConnection) {
      return await operation();
    } else {
      operation();
      return offlineResult;
    }
  }

  Future<T> executeRead<T>({required Future<T> Function() operation}) async {
    return await operation();
  }
}

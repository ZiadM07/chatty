import 'dart:async';
import 'package:injectable/injectable.dart';
import 'network.dart';

/// Helper class for Firestore operations that handles offline writes properly
/// When offline, writes are queued locally without awaiting server confirmation
@lazySingleton
class FirestoreOfflineHelper {
  final NetworkInfo _networkInfo;
  static const Duration _networkCheckTimeout = Duration(seconds: 3);

  FirestoreOfflineHelper(this._networkInfo);

  /// Check network connectivity with timeout
  /// Returns false if check times out or no connection
  Future<bool> _checkConnection() async {
    try {
      return await _networkInfo.isConnected.timeout(
        _networkCheckTimeout,
        onTimeout: () => false,
      );
    } catch (e) {
      // If check fails, assume offline
      return false;
    }
  }

  /// Execute a Firestore write operation
  /// If online: awaits server confirmation
  /// If offline: queues locally without awaiting (returns immediately)
  Future<void> executeWrite({
    required Future<void> Function() operation,
  }) async {
    final hasConnection = await _checkConnection();

    if (hasConnection) {
      // Online: await for server confirmation
      await operation();
    } else {
      // Offline: queue locally without awaiting
      // Firestore will sync automatically when connection is restored
      operation();
    }
  }

  /// Execute a Firestore write operation that returns a value
  /// If online: awaits server confirmation and returns the result
  /// If offline: queues locally and returns a placeholder value immediately
  Future<T> executeWriteWithResult<T>({
    required Future<T> Function() operation,
    required T offlineResult,
  }) async {
    final hasConnection = await _checkConnection();

    if (hasConnection) {
      // Online: await for server confirmation
      return await operation();
    } else {
      // Offline: queue locally without awaiting
      // Return the offline result immediately
      operation();
      return offlineResult;
    }
  }

  /// Execute a Firestore read operation (always awaits, uses cache when offline)
  Future<T> executeRead<T>({required Future<T> Function() operation}) async {
    // Reads always await, Firestore will use cache when offline
    return await operation();
  }
}

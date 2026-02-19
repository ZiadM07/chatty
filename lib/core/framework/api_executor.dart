import 'package:injectable/injectable.dart';

import 'failure.dart';
import 'kprint.dart';
import 'network.dart';

abstract class ApiExecutor {
  Future<T> call<T>({required Future<T> Function() apiCall});
}

@LazySingleton(as: ApiExecutor)
class ApiExecutorImpl implements ApiExecutor {
  final NetworkInfo networkInfo;

  ApiExecutorImpl(this.networkInfo);

  @override
  Future<T> call<T>({required Future<T> Function() apiCall}) async {
    final hasConnection = await networkInfo.isConnected;
    if (!hasConnection) {
      throw Failure(500, 'No Internet');
    }
    try {
      return await apiCall.call();
    } catch (error, s) {
      kPrint("API Error: $error");
      kPrint(s);
      throw Failure(600, error.toString());
    }
  }
}

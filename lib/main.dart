import 'package:Chatty/core/constants/app_endpoints.dart';
import 'package:Chatty/core/constants/exports.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/di/injectable.dart';
import 'core/framework/notification_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Supabase.initialize(
    url: AppEndpoints.supabaseUrl,
    anonKey: AppEndpoints.supabaseAnonKey,
  );
  if (kDebugMode) OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize(AppEndpoints.oneSignalAppId);
  await configureDependencies();
  await getIt<NotificationService>().initialize();
  runApp(const ChattyApp());
}

import 'package:chatty/core/constants/app_endpoints.dart';
import 'package:chatty/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'core/di/injectable.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Supabase.initialize(
    url: AppEndpoints.supabaseUrl,
    anonKey: AppEndpoints.supabaseAnonKey,
  );
  await configureDependencies();
  runApp(const ChattyApp());
}

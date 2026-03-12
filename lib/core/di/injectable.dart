import 'package:Chatty/core/framework/storage_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:location/location.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/exports.dart';
import 'injectable.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async {
  await getIt.init();
}

@module
abstract class InjectionModule {
  @preResolve
  Future<SharedPreferences> providePrefs() => SharedPreferences.getInstance();

  @singleton
  StorageService storageService(SharedPreferences prefs) =>
      SharedPreferencesService(prefs);

  @singleton
  AppPreferences appPreferences(StorageService storage) =>
      AppPreferences(storage);

  @singleton
  AppRouter router(AppPreferences prefs) => AppRouter(prefs);

  @lazySingleton
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;

  @lazySingleton
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  @lazySingleton
  SupabaseClient get client => Supabase.instance.client;

  @singleton
  GlobalKey<NavigatorState> get navigatorKey => GlobalKey<NavigatorState>();

  @injectable
  InternetConnection get internetConnectionChecker => InternetConnection();

  @injectable
  GlobalKey<FormState> get globalKey => GlobalKey<FormState>();

  @injectable
  TextEditingController get textController => TextEditingController();

  @injectable
  ImagePicker get picker => ImagePicker();

  @injectable
  Location get location => Location();

  @lazySingleton
  Dio get dio => Dio();
}

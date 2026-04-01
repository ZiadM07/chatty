// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:dio/dio.dart' as _i361;
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:get_it/get_it.dart' as _i174;
import 'package:image_picker/image_picker.dart' as _i183;
import 'package:injectable/injectable.dart' as _i526;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart'
    as _i161;
import 'package:location/location.dart' as _i645;
import 'package:supabase_flutter/supabase_flutter.dart' as _i454;

import '../../features/auth/cubits/auth_cubit.dart' as _i554;
import '../../features/auth/data/data_sources/auth_data_source.dart' as _i933;
import '../../features/auth/data/repositories/auth_repositories.dart' as _i613;
import '../../features/chats/cubits/chat_cubit.dart' as _i1008;
import '../../features/chats/cubits/chat_info_cubit.dart' as _i239;
import '../../features/chats/cubits/chat_media_cubit.dart' as _i180;
import '../../features/chats/cubits/conversations_cubit.dart' as _i1021;
import '../../features/chats/data/data_source/chat_data_source.dart' as _i206;
import '../../features/chats/data/repositories/chat_repository.dart' as _i737;
import '../../features/profile/cubits/notifications_cubit.dart' as _i769;
import '../../features/profile/cubits/profile_cubit.dart' as _i877;
import '../../features/profile/data/data_source/profile_data_source.dart'
    as _i519;
import '../../features/profile/data/repositories/profile_repositories.dart'
    as _i996;
import '../../features/shared/cubits/app_cubit.dart' as _i564;
import '../../features/shared/data/data_sources/storage_data_source.dart'
    as _i120;
import '../../features/stories/cubits/stories_cubit.dart' as _i149;
import '../../features/stories/cubits/story_viewer_cubit.dart' as _i24;
import '../../features/stories/data/data_sources/story_data_source.dart'
    as _i422;
import '../../features/stories/data/repositories/story_repository.dart'
    as _i621;
import '../../features/users/cubits/users_cubit.dart' as _i921;
import '../../features/users/data/data_sources/users_data_source.dart' as _i295;
import '../../features/users/data/repositories/users_repository.dart' as _i190;
import '../constants/exports.dart' as _i600;
import '../framework/api_executor.dart' as _i142;
import '../framework/audio_service.dart' as _i946;
import '../framework/firestore_offline_helper.dart' as _i279;
import '../framework/in_app_sound_service.dart' as _i967;
import '../framework/network.dart' as _i159;
import '../framework/notification_service.dart' as _i39;
import '../framework/permissions.dart' as _i349;
import '../framework/storage_service.dart' as _i942;
import 'injectable.dart' as _i1027;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final injectionModule = _$InjectionModule();
    gh.factory<_i161.InternetConnection>(
      () => injectionModule.internetConnectionChecker,
    );
    gh.factory<_i600.GlobalKey<_i600.FormState>>(
      () => injectionModule.globalKey,
    );
    gh.factory<_i600.TextEditingController>(
      () => injectionModule.textController,
    );
    gh.factory<_i183.ImagePicker>(() => injectionModule.picker);
    gh.factory<_i645.Location>(() => injectionModule.location);
    await gh.factoryAsync<_i600.SharedPreferences>(
      () => injectionModule.providePrefs(),
      preResolve: true,
    );
    gh.singleton<_i600.GlobalKey<_i600.NavigatorState>>(
      () => injectionModule.navigatorKey,
    );
    gh.singleton<_i967.InAppSoundService>(() => _i967.InAppSoundService());
    gh.lazySingleton<_i59.FirebaseAuth>(() => injectionModule.firebaseAuth);
    gh.lazySingleton<_i974.FirebaseFirestore>(() => injectionModule.firestore);
    gh.lazySingleton<_i454.SupabaseClient>(() => injectionModule.client);
    gh.lazySingleton<_i361.Dio>(() => injectionModule.dio);
    gh.lazySingleton<_i946.AudioService>(() => _i946.AudioService());
    gh.singleton<_i942.StorageService>(
      () => injectionModule.storageService(gh<_i600.SharedPreferences>()),
    );
    gh.lazySingleton<_i120.StorageDataSource>(
      () => _i120.SupabaseStorageDataSourceImpl(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i933.AuthDataSource>(
      () => _i933.AuthDataSourceImpl(
        gh<_i59.FirebaseAuth>(),
        gh<_i974.FirebaseFirestore>(),
      ),
    );
    gh.lazySingleton<_i206.ChatDataSource>(
      () => _i206.ChatDataSourceImpl(gh<_i974.FirebaseFirestore>()),
    );
    gh.lazySingleton<_i422.StoryDataSource>(
      () => _i422.StoryDataSourceImpl(gh<_i974.FirebaseFirestore>()),
    );
    gh.lazySingleton<_i737.ChatRepository>(
      () => _i737.ChatRepository(
        gh<_i206.ChatDataSource>(),
        gh<_i120.StorageDataSource>(),
      ),
    );
    gh.lazySingleton<_i349.Permissions>(
      () => _i349.PermissionsInfo(location: gh<_i645.Location>()),
    );
    gh.factory<_i180.ChatMediaCubit>(
      () => _i180.ChatMediaCubit(gh<_i737.ChatRepository>()),
    );
    gh.lazySingleton<_i519.ProfileDataSource>(
      () => _i519.ProfileDataSourceImpl(gh<_i974.FirebaseFirestore>()),
    );
    gh.factory<_i159.NetworkInfo>(
      () => _i159.NetworkInfoImpl(gh<_i161.InternetConnection>()),
    );
    gh.lazySingleton<_i295.UsersDataSource>(
      () => _i295.UsersDataSourceImpl(gh<_i974.FirebaseFirestore>()),
    );
    gh.lazySingleton<_i142.ApiExecutor>(
      () => _i142.ApiExecutorImpl(gh<_i159.NetworkInfo>()),
    );
    gh.singleton<_i600.AppPreferences>(
      () => injectionModule.appPreferences(gh<_i942.StorageService>()),
    );
    gh.singleton<_i600.AppRouter>(
      () => injectionModule.router(gh<_i600.AppPreferences>()),
    );
    gh.singleton<_i39.NotificationService>(
      () => _i39.NotificationService(gh<_i600.AppPreferences>()),
    );
    gh.lazySingleton<_i996.ProfileRepository>(
      () => _i996.ProfileRepository(
        gh<_i519.ProfileDataSource>(),
        gh<_i120.StorageDataSource>(),
      ),
    );
    gh.lazySingleton<_i613.AuthRepository>(
      () => _i613.AuthRepository(
        gh<_i933.AuthDataSource>(),
        gh<_i120.StorageDataSource>(),
        gh<_i206.ChatDataSource>(),
      ),
    );
    gh.lazySingleton<_i279.FirestoreOfflineHelper>(
      () => _i279.FirestoreOfflineHelper(gh<_i159.NetworkInfo>()),
    );
    gh.lazySingleton<_i554.AuthCubit>(
      () => _i554.AuthCubit(
        gh<_i613.AuthRepository>(),
        gh<_i39.NotificationService>(),
      ),
    );
    gh.factory<_i877.ProfileCubit>(
      () => _i877.ProfileCubit(
        gh<_i996.ProfileRepository>(),
        gh<_i613.AuthRepository>(),
      ),
    );
    gh.factory<_i1008.ChatCubit>(
      () => _i1008.ChatCubit(
        gh<_i737.ChatRepository>(),
        gh<_i39.NotificationService>(),
      ),
    );
    gh.singleton<_i564.AppCubit>(
      () => _i564.AppCubit(gh<_i600.AppPreferences>()),
    );
    gh.lazySingleton<_i190.UsersRepository>(
      () => _i190.UsersRepository(gh<_i295.UsersDataSource>()),
    );
    gh.singleton<_i769.NotificationsCubit>(
      () => _i769.NotificationsCubit(
        gh<_i600.AppPreferences>(),
        gh<_i39.NotificationService>(),
      ),
    );
    gh.factory<_i921.UsersCubit>(
      () => _i921.UsersCubit(gh<_i190.UsersRepository>()),
    );
    gh.lazySingleton<_i621.StoryRepository>(
      () => _i621.StoryRepository(
        gh<_i422.StoryDataSource>(),
        gh<_i120.StorageDataSource>(),
        gh<_i190.UsersRepository>(),
        gh<_i737.ChatRepository>(),
      ),
    );
    gh.factory<_i239.ChatInfoCubit>(
      () => _i239.ChatInfoCubit(
        gh<_i190.UsersRepository>(),
        gh<_i737.ChatRepository>(),
        gh<_i600.AppPreferences>(),
      ),
    );
    gh.factory<_i1021.ConversationsCubit>(
      () => _i1021.ConversationsCubit(
        gh<_i737.ChatRepository>(),
        gh<_i190.UsersRepository>(),
      ),
    );
    gh.factory<_i149.StoriesCubit>(
      () => _i149.StoriesCubit(gh<_i621.StoryRepository>()),
    );
    gh.factory<_i24.StoryViewerCubit>(
      () => _i24.StoryViewerCubit(gh<_i621.StoryRepository>()),
    );
    return this;
  }
}

class _$InjectionModule extends _i1027.InjectionModule {}

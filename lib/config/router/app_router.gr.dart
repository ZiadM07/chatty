// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i21;
import 'package:Chatty/config/router/app_router.dart' as _i2;
import 'package:Chatty/core/constants/exports.dart' as _i22;
import 'package:Chatty/features/auth/ui/screens/fill_profile_screen.dart'
    as _i9;
import 'package:Chatty/features/auth/ui/screens/login_screen.dart' as _i11;
import 'package:Chatty/features/auth/ui/screens/signup_screen.dart' as _i16;
import 'package:Chatty/features/auth/ui/screens/splash_screen.dart' as _i17;
import 'package:Chatty/features/auth/ui/screens/welcome_screen.dart' as _i20;
import 'package:Chatty/features/chats/ui/chat/chat_screen.dart' as _i5;
import 'package:Chatty/features/chats/ui/conversations/conversations_screen.dart'
    as _i8;
import 'package:Chatty/features/chats/ui/info/chat_info_screen.dart' as _i3;
import 'package:Chatty/features/chats/ui/media/chat_media_screen.dart' as _i4;
import 'package:Chatty/features/main/main_screen.dart' as _i12;
import 'package:Chatty/features/profile/ui/screens/chat_wallpaper_screen.dart'
    as _i6;
import 'package:Chatty/features/profile/ui/screens/chats_settings_screen.dart'
    as _i7;
import 'package:Chatty/features/profile/ui/screens/language_settings_screen.dart'
    as _i10;
import 'package:Chatty/features/profile/ui/screens/notification_settings_screen.dart'
    as _i13;
import 'package:Chatty/features/profile/ui/screens/profile_screen.dart' as _i14;
import 'package:Chatty/features/profile/ui/screens/profile_settings_screen.dart'
    as _i15;
import 'package:Chatty/features/stories/ui/add_story/add_story_screen.dart'
    as _i1;
import 'package:Chatty/features/stories/ui/story_viewer/story_viewer_screen.dart'
    as _i18;
import 'package:Chatty/features/users/ui/screens/users_screen.dart' as _i19;

/// generated route for
/// [_i1.AddStoryScreen]
class AddStoryRoute extends _i21.PageRouteInfo<void> {
  const AddStoryRoute({List<_i21.PageRouteInfo>? children})
    : super(AddStoryRoute.name, initialChildren: children);

  static const String name = 'AddStoryRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i1.AddStoryScreen();
    },
  );
}

/// generated route for
/// [_i2.Authenticated]
class AuthenticatedRoutes extends _i21.PageRouteInfo<void> {
  const AuthenticatedRoutes({List<_i21.PageRouteInfo>? children})
    : super(AuthenticatedRoutes.name, initialChildren: children);

  static const String name = 'AuthenticatedRoutes';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return _i21.WrappedRoute(child: const _i2.Authenticated());
    },
  );
}

/// generated route for
/// [_i3.ChatInfoScreen]
class ChatInfoRoute extends _i21.PageRouteInfo<ChatInfoRouteArgs> {
  ChatInfoRoute({
    _i22.Key? key,
    String? uid,
    String? chatId,
    List<_i21.PageRouteInfo>? children,
  }) : super(
         ChatInfoRoute.name,
         args: ChatInfoRouteArgs(key: key, uid: uid, chatId: chatId),
         initialChildren: children,
       );

  static const String name = 'ChatInfoRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ChatInfoRouteArgs>(
        orElse: () => const ChatInfoRouteArgs(),
      );
      return _i21.WrappedRoute(
        child: _i3.ChatInfoScreen(
          key: args.key,
          uid: args.uid,
          chatId: args.chatId,
        ),
      );
    },
  );
}

class ChatInfoRouteArgs {
  const ChatInfoRouteArgs({this.key, this.uid, this.chatId});

  final _i22.Key? key;

  final String? uid;

  final String? chatId;

  @override
  String toString() {
    return 'ChatInfoRouteArgs{key: $key, uid: $uid, chatId: $chatId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ChatInfoRouteArgs) return false;
    return key == other.key && uid == other.uid && chatId == other.chatId;
  }

  @override
  int get hashCode => key.hashCode ^ uid.hashCode ^ chatId.hashCode;
}

/// generated route for
/// [_i4.ChatMediaScreen]
class ChatMediaRoute extends _i21.PageRouteInfo<ChatMediaRouteArgs> {
  ChatMediaRoute({
    _i22.Key? key,
    required String chatId,
    List<_i21.PageRouteInfo>? children,
  }) : super(
         ChatMediaRoute.name,
         args: ChatMediaRouteArgs(key: key, chatId: chatId),
         initialChildren: children,
       );

  static const String name = 'ChatMediaRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ChatMediaRouteArgs>();
      return _i21.WrappedRoute(
        child: _i4.ChatMediaScreen(key: args.key, chatId: args.chatId),
      );
    },
  );
}

class ChatMediaRouteArgs {
  const ChatMediaRouteArgs({this.key, required this.chatId});

  final _i22.Key? key;

  final String chatId;

  @override
  String toString() {
    return 'ChatMediaRouteArgs{key: $key, chatId: $chatId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ChatMediaRouteArgs) return false;
    return key == other.key && chatId == other.chatId;
  }

  @override
  int get hashCode => key.hashCode ^ chatId.hashCode;
}

/// generated route for
/// [_i5.ChatScreen]
class ChatRoute extends _i21.PageRouteInfo<ChatRouteArgs> {
  ChatRoute({
    _i22.Key? key,
    required String chatId,
    List<_i21.PageRouteInfo>? children,
  }) : super(
         ChatRoute.name,
         args: ChatRouteArgs(key: key, chatId: chatId),
         initialChildren: children,
       );

  static const String name = 'ChatRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ChatRouteArgs>();
      return _i21.WrappedRoute(
        child: _i5.ChatScreen(key: args.key, chatId: args.chatId),
      );
    },
  );
}

class ChatRouteArgs {
  const ChatRouteArgs({this.key, required this.chatId});

  final _i22.Key? key;

  final String chatId;

  @override
  String toString() {
    return 'ChatRouteArgs{key: $key, chatId: $chatId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ChatRouteArgs) return false;
    return key == other.key && chatId == other.chatId;
  }

  @override
  int get hashCode => key.hashCode ^ chatId.hashCode;
}

/// generated route for
/// [_i6.ChatWallpaperScreen]
class ChatWallpaperRoute extends _i21.PageRouteInfo<void> {
  const ChatWallpaperRoute({List<_i21.PageRouteInfo>? children})
    : super(ChatWallpaperRoute.name, initialChildren: children);

  static const String name = 'ChatWallpaperRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i6.ChatWallpaperScreen();
    },
  );
}

/// generated route for
/// [_i7.ChatsSettingsScreen]
class ChatsSettingsRoute extends _i21.PageRouteInfo<void> {
  const ChatsSettingsRoute({List<_i21.PageRouteInfo>? children})
    : super(ChatsSettingsRoute.name, initialChildren: children);

  static const String name = 'ChatsSettingsRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i7.ChatsSettingsScreen();
    },
  );
}

/// generated route for
/// [_i8.ConversationsScreen]
class ConversationsRoute extends _i21.PageRouteInfo<void> {
  const ConversationsRoute({List<_i21.PageRouteInfo>? children})
    : super(ConversationsRoute.name, initialChildren: children);

  static const String name = 'ConversationsRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i8.ConversationsScreen();
    },
  );
}

/// generated route for
/// [_i9.FillProfileScreen]
class FillProfileRoute extends _i21.PageRouteInfo<void> {
  const FillProfileRoute({List<_i21.PageRouteInfo>? children})
    : super(FillProfileRoute.name, initialChildren: children);

  static const String name = 'FillProfileRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i9.FillProfileScreen();
    },
  );
}

/// generated route for
/// [_i10.LanguageSettingsScreen]
class LanguageSettingsRoute extends _i21.PageRouteInfo<void> {
  const LanguageSettingsRoute({List<_i21.PageRouteInfo>? children})
    : super(LanguageSettingsRoute.name, initialChildren: children);

  static const String name = 'LanguageSettingsRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i10.LanguageSettingsScreen();
    },
  );
}

/// generated route for
/// [_i11.LoginScreen]
class LoginRoute extends _i21.PageRouteInfo<void> {
  const LoginRoute({List<_i21.PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i11.LoginScreen();
    },
  );
}

/// generated route for
/// [_i12.MainScreen]
class MainRoute extends _i21.PageRouteInfo<void> {
  const MainRoute({List<_i21.PageRouteInfo>? children})
    : super(MainRoute.name, initialChildren: children);

  static const String name = 'MainRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i12.MainScreen();
    },
  );
}

/// generated route for
/// [_i13.NotificationSettingsScreen]
class NotificationSettingsRoute extends _i21.PageRouteInfo<void> {
  const NotificationSettingsRoute({List<_i21.PageRouteInfo>? children})
    : super(NotificationSettingsRoute.name, initialChildren: children);

  static const String name = 'NotificationSettingsRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return _i21.WrappedRoute(child: const _i13.NotificationSettingsScreen());
    },
  );
}

/// generated route for
/// [_i14.ProfileScreen]
class ProfileRoute extends _i21.PageRouteInfo<void> {
  const ProfileRoute({List<_i21.PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i14.ProfileScreen();
    },
  );
}

/// generated route for
/// [_i15.ProfileSettingsScreen]
class ProfileSettingsRoute extends _i21.PageRouteInfo<void> {
  const ProfileSettingsRoute({List<_i21.PageRouteInfo>? children})
    : super(ProfileSettingsRoute.name, initialChildren: children);

  static const String name = 'ProfileSettingsRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i15.ProfileSettingsScreen();
    },
  );
}

/// generated route for
/// [_i16.SignupScreen]
class SignupRoute extends _i21.PageRouteInfo<void> {
  const SignupRoute({List<_i21.PageRouteInfo>? children})
    : super(SignupRoute.name, initialChildren: children);

  static const String name = 'SignupRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i16.SignupScreen();
    },
  );
}

/// generated route for
/// [_i17.SplashScreen]
class SplashRoute extends _i21.PageRouteInfo<void> {
  const SplashRoute({List<_i21.PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i17.SplashScreen();
    },
  );
}

/// generated route for
/// [_i18.StoryViewerScreen]
class StoryViewerRoute extends _i21.PageRouteInfo<StoryViewerRouteArgs> {
  StoryViewerRoute({
    _i22.Key? key,
    required String ownerUid,
    List<_i21.PageRouteInfo>? children,
  }) : super(
         StoryViewerRoute.name,
         args: StoryViewerRouteArgs(key: key, ownerUid: ownerUid),
         initialChildren: children,
       );

  static const String name = 'StoryViewerRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<StoryViewerRouteArgs>();
      return _i21.WrappedRoute(
        child: _i18.StoryViewerScreen(key: args.key, ownerUid: args.ownerUid),
      );
    },
  );
}

class StoryViewerRouteArgs {
  const StoryViewerRouteArgs({this.key, required this.ownerUid});

  final _i22.Key? key;

  final String ownerUid;

  @override
  String toString() {
    return 'StoryViewerRouteArgs{key: $key, ownerUid: $ownerUid}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! StoryViewerRouteArgs) return false;
    return key == other.key && ownerUid == other.ownerUid;
  }

  @override
  int get hashCode => key.hashCode ^ ownerUid.hashCode;
}

/// generated route for
/// [_i2.Unauthenticated]
class UnauthenticatedRoutes extends _i21.PageRouteInfo<void> {
  const UnauthenticatedRoutes({List<_i21.PageRouteInfo>? children})
    : super(UnauthenticatedRoutes.name, initialChildren: children);

  static const String name = 'UnauthenticatedRoutes';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i2.Unauthenticated();
    },
  );
}

/// generated route for
/// [_i19.UsersScreen]
class UsersRoute extends _i21.PageRouteInfo<void> {
  const UsersRoute({List<_i21.PageRouteInfo>? children})
    : super(UsersRoute.name, initialChildren: children);

  static const String name = 'UsersRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i19.UsersScreen();
    },
  );
}

/// generated route for
/// [_i20.WelcomeScreen]
class WelcomeRoute extends _i21.PageRouteInfo<void> {
  const WelcomeRoute({List<_i21.PageRouteInfo>? children})
    : super(WelcomeRoute.name, initialChildren: children);

  static const String name = 'WelcomeRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i20.WelcomeScreen();
    },
  );
}

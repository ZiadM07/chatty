// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i24;
import 'package:Chatty/config/router/app_router.dart' as _i2;
import 'package:Chatty/core/constants/exports.dart' as _i25;
import 'package:Chatty/features/auth/ui/screens/email_verfication_screen.dart'
    as _i10;
import 'package:Chatty/features/auth/ui/screens/fill_profile_screen.dart'
    as _i11;
import 'package:Chatty/features/auth/ui/screens/forget_password_screen.dart'
    as _i12;
import 'package:Chatty/features/auth/ui/screens/login_screen.dart' as _i14;
import 'package:Chatty/features/auth/ui/screens/signup_screen.dart' as _i19;
import 'package:Chatty/features/auth/ui/screens/splash_screen.dart' as _i20;
import 'package:Chatty/features/auth/ui/screens/welcome_screen.dart' as _i23;
import 'package:Chatty/features/chats/ui/chat/chat_screen.dart' as _i6;
import 'package:Chatty/features/chats/ui/conversations/conversations_screen.dart'
    as _i9;
import 'package:Chatty/features/chats/ui/info/chat_info_screen.dart' as _i4;
import 'package:Chatty/features/chats/ui/media/chat_media_screen.dart' as _i5;
import 'package:Chatty/features/main/main_screen.dart' as _i15;
import 'package:Chatty/features/profile/ui/screens/change_password_screen.dart'
    as _i3;
import 'package:Chatty/features/profile/ui/screens/chat_wallpaper_screen.dart'
    as _i7;
import 'package:Chatty/features/profile/ui/screens/chats_settings_screen.dart'
    as _i8;
import 'package:Chatty/features/profile/ui/screens/language_settings_screen.dart'
    as _i13;
import 'package:Chatty/features/profile/ui/screens/notification_settings_screen.dart'
    as _i16;
import 'package:Chatty/features/profile/ui/screens/profile_screen.dart' as _i17;
import 'package:Chatty/features/profile/ui/screens/profile_settings_screen.dart'
    as _i18;
import 'package:Chatty/features/stories/ui/add_story/add_story_screen.dart'
    as _i1;
import 'package:Chatty/features/stories/ui/story_viewer/story_viewer_screen.dart'
    as _i21;
import 'package:Chatty/features/users/ui/screens/users_screen.dart' as _i22;

/// generated route for
/// [_i1.AddStoryScreen]
class AddStoryRoute extends _i24.PageRouteInfo<void> {
  const AddStoryRoute({List<_i24.PageRouteInfo>? children})
    : super(AddStoryRoute.name, initialChildren: children);

  static const String name = 'AddStoryRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      return const _i1.AddStoryScreen();
    },
  );
}

/// generated route for
/// [_i2.Authenticated]
class AuthenticatedRoutes extends _i24.PageRouteInfo<void> {
  const AuthenticatedRoutes({List<_i24.PageRouteInfo>? children})
    : super(AuthenticatedRoutes.name, initialChildren: children);

  static const String name = 'AuthenticatedRoutes';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      return _i24.WrappedRoute(child: const _i2.Authenticated());
    },
  );
}

/// generated route for
/// [_i3.ChangePasswordScreen]
class ChangePasswordRoute extends _i24.PageRouteInfo<void> {
  const ChangePasswordRoute({List<_i24.PageRouteInfo>? children})
    : super(ChangePasswordRoute.name, initialChildren: children);

  static const String name = 'ChangePasswordRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      return const _i3.ChangePasswordScreen();
    },
  );
}

/// generated route for
/// [_i4.ChatInfoScreen]
class ChatInfoRoute extends _i24.PageRouteInfo<ChatInfoRouteArgs> {
  ChatInfoRoute({
    _i25.Key? key,
    String? uid,
    String? chatId,
    List<_i24.PageRouteInfo>? children,
  }) : super(
         ChatInfoRoute.name,
         args: ChatInfoRouteArgs(key: key, uid: uid, chatId: chatId),
         initialChildren: children,
       );

  static const String name = 'ChatInfoRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ChatInfoRouteArgs>(
        orElse: () => const ChatInfoRouteArgs(),
      );
      return _i24.WrappedRoute(
        child: _i4.ChatInfoScreen(
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

  final _i25.Key? key;

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
/// [_i5.ChatMediaScreen]
class ChatMediaRoute extends _i24.PageRouteInfo<ChatMediaRouteArgs> {
  ChatMediaRoute({
    _i25.Key? key,
    required String chatId,
    List<_i24.PageRouteInfo>? children,
  }) : super(
         ChatMediaRoute.name,
         args: ChatMediaRouteArgs(key: key, chatId: chatId),
         initialChildren: children,
       );

  static const String name = 'ChatMediaRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ChatMediaRouteArgs>();
      return _i24.WrappedRoute(
        child: _i5.ChatMediaScreen(key: args.key, chatId: args.chatId),
      );
    },
  );
}

class ChatMediaRouteArgs {
  const ChatMediaRouteArgs({this.key, required this.chatId});

  final _i25.Key? key;

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
/// [_i6.ChatScreen]
class ChatRoute extends _i24.PageRouteInfo<ChatRouteArgs> {
  ChatRoute({
    _i25.Key? key,
    required String chatId,
    List<_i24.PageRouteInfo>? children,
  }) : super(
         ChatRoute.name,
         args: ChatRouteArgs(key: key, chatId: chatId),
         initialChildren: children,
       );

  static const String name = 'ChatRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ChatRouteArgs>();
      return _i24.WrappedRoute(
        child: _i6.ChatScreen(key: args.key, chatId: args.chatId),
      );
    },
  );
}

class ChatRouteArgs {
  const ChatRouteArgs({this.key, required this.chatId});

  final _i25.Key? key;

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
/// [_i7.ChatWallpaperScreen]
class ChatWallpaperRoute extends _i24.PageRouteInfo<void> {
  const ChatWallpaperRoute({List<_i24.PageRouteInfo>? children})
    : super(ChatWallpaperRoute.name, initialChildren: children);

  static const String name = 'ChatWallpaperRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      return const _i7.ChatWallpaperScreen();
    },
  );
}

/// generated route for
/// [_i8.ChatsSettingsScreen]
class ChatsSettingsRoute extends _i24.PageRouteInfo<void> {
  const ChatsSettingsRoute({List<_i24.PageRouteInfo>? children})
    : super(ChatsSettingsRoute.name, initialChildren: children);

  static const String name = 'ChatsSettingsRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      return const _i8.ChatsSettingsScreen();
    },
  );
}

/// generated route for
/// [_i9.ConversationsScreen]
class ConversationsRoute extends _i24.PageRouteInfo<void> {
  const ConversationsRoute({List<_i24.PageRouteInfo>? children})
    : super(ConversationsRoute.name, initialChildren: children);

  static const String name = 'ConversationsRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      return const _i9.ConversationsScreen();
    },
  );
}

/// generated route for
/// [_i10.EmailVerificationScreen]
class EmailVerificationRoute extends _i24.PageRouteInfo<void> {
  const EmailVerificationRoute({List<_i24.PageRouteInfo>? children})
    : super(EmailVerificationRoute.name, initialChildren: children);

  static const String name = 'EmailVerificationRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      return const _i10.EmailVerificationScreen();
    },
  );
}

/// generated route for
/// [_i11.FillProfileScreen]
class FillProfileRoute extends _i24.PageRouteInfo<void> {
  const FillProfileRoute({List<_i24.PageRouteInfo>? children})
    : super(FillProfileRoute.name, initialChildren: children);

  static const String name = 'FillProfileRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      return const _i11.FillProfileScreen();
    },
  );
}

/// generated route for
/// [_i12.ForgotPasswordScreen]
class ForgotPasswordRoute extends _i24.PageRouteInfo<void> {
  const ForgotPasswordRoute({List<_i24.PageRouteInfo>? children})
    : super(ForgotPasswordRoute.name, initialChildren: children);

  static const String name = 'ForgotPasswordRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      return const _i12.ForgotPasswordScreen();
    },
  );
}

/// generated route for
/// [_i13.LanguageSettingsScreen]
class LanguageSettingsRoute extends _i24.PageRouteInfo<void> {
  const LanguageSettingsRoute({List<_i24.PageRouteInfo>? children})
    : super(LanguageSettingsRoute.name, initialChildren: children);

  static const String name = 'LanguageSettingsRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      return const _i13.LanguageSettingsScreen();
    },
  );
}

/// generated route for
/// [_i14.LoginScreen]
class LoginRoute extends _i24.PageRouteInfo<void> {
  const LoginRoute({List<_i24.PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      return const _i14.LoginScreen();
    },
  );
}

/// generated route for
/// [_i15.MainScreen]
class MainRoute extends _i24.PageRouteInfo<void> {
  const MainRoute({List<_i24.PageRouteInfo>? children})
    : super(MainRoute.name, initialChildren: children);

  static const String name = 'MainRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      return const _i15.MainScreen();
    },
  );
}

/// generated route for
/// [_i16.NotificationSettingsScreen]
class NotificationSettingsRoute extends _i24.PageRouteInfo<void> {
  const NotificationSettingsRoute({List<_i24.PageRouteInfo>? children})
    : super(NotificationSettingsRoute.name, initialChildren: children);

  static const String name = 'NotificationSettingsRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      return _i24.WrappedRoute(child: const _i16.NotificationSettingsScreen());
    },
  );
}

/// generated route for
/// [_i17.ProfileScreen]
class ProfileRoute extends _i24.PageRouteInfo<void> {
  const ProfileRoute({List<_i24.PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      return const _i17.ProfileScreen();
    },
  );
}

/// generated route for
/// [_i18.ProfileSettingsScreen]
class ProfileSettingsRoute extends _i24.PageRouteInfo<void> {
  const ProfileSettingsRoute({List<_i24.PageRouteInfo>? children})
    : super(ProfileSettingsRoute.name, initialChildren: children);

  static const String name = 'ProfileSettingsRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      return const _i18.ProfileSettingsScreen();
    },
  );
}

/// generated route for
/// [_i19.SignupScreen]
class SignupRoute extends _i24.PageRouteInfo<void> {
  const SignupRoute({List<_i24.PageRouteInfo>? children})
    : super(SignupRoute.name, initialChildren: children);

  static const String name = 'SignupRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      return const _i19.SignupScreen();
    },
  );
}

/// generated route for
/// [_i20.SplashScreen]
class SplashRoute extends _i24.PageRouteInfo<void> {
  const SplashRoute({List<_i24.PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      return const _i20.SplashScreen();
    },
  );
}

/// generated route for
/// [_i21.StoryViewerScreen]
class StoryViewerRoute extends _i24.PageRouteInfo<StoryViewerRouteArgs> {
  StoryViewerRoute({
    _i25.Key? key,
    required String ownerUid,
    List<_i24.PageRouteInfo>? children,
  }) : super(
         StoryViewerRoute.name,
         args: StoryViewerRouteArgs(key: key, ownerUid: ownerUid),
         initialChildren: children,
       );

  static const String name = 'StoryViewerRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<StoryViewerRouteArgs>();
      return _i24.WrappedRoute(
        child: _i21.StoryViewerScreen(key: args.key, ownerUid: args.ownerUid),
      );
    },
  );
}

class StoryViewerRouteArgs {
  const StoryViewerRouteArgs({this.key, required this.ownerUid});

  final _i25.Key? key;

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
class UnauthenticatedRoutes extends _i24.PageRouteInfo<void> {
  const UnauthenticatedRoutes({List<_i24.PageRouteInfo>? children})
    : super(UnauthenticatedRoutes.name, initialChildren: children);

  static const String name = 'UnauthenticatedRoutes';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      return const _i2.Unauthenticated();
    },
  );
}

/// generated route for
/// [_i22.UsersScreen]
class UsersRoute extends _i24.PageRouteInfo<void> {
  const UsersRoute({List<_i24.PageRouteInfo>? children})
    : super(UsersRoute.name, initialChildren: children);

  static const String name = 'UsersRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      return const _i22.UsersScreen();
    },
  );
}

/// generated route for
/// [_i23.WelcomeScreen]
class WelcomeRoute extends _i24.PageRouteInfo<void> {
  const WelcomeRoute({List<_i24.PageRouteInfo>? children})
    : super(WelcomeRoute.name, initialChildren: children);

  static const String name = 'WelcomeRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      return const _i23.WelcomeScreen();
    },
  );
}

import 'package:Chatty/core/constants/exports.dart' hide TestRoute;
import 'package:Chatty/features/chats/cubits/conversations_cubit.dart';
import 'package:Chatty/features/stories/cubits/stories_cubit.dart';
import 'package:Chatty/features/users/cubits/users_cubit.dart';
import '../../core/constants/exports.dart';
import '../../core/di/injectable.dart';
import '../../features/auth/cubits/auth_cubit.dart';
import '../../features/profile/cubits/profile_cubit.dart';
import 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends RootStackRouter {
  final AppPreferences prefs;

  AppRouter(this.prefs);

  @override
  List<AutoRoute> get routes => [
    CustomRoute(
      page: SplashRoute.page,
      initial: true,
      transitionsBuilder: TransitionsBuilders.fadeIn,
      duration: const Duration(milliseconds: 220),
    ),

    CustomRoute(
      page: UnauthenticatedRoutes.page,
      transitionsBuilder: TransitionsBuilders.fadeIn,
      duration: const Duration(milliseconds: 220),
      children: [
        CustomRoute(
          page: WelcomeRoute.page,
          initial: true,
          transitionsBuilder: TransitionsBuilders.fadeIn,
          duration: const Duration(milliseconds: 220),
        ),
        CustomRoute(
          page: LoginRoute.page,
          transitionsBuilder: TransitionsBuilders.fadeIn,
          duration: const Duration(milliseconds: 220),
        ),
        CustomRoute(
          page: ForgotPasswordRoute.page,
          transitionsBuilder: TransitionsBuilders.fadeIn,
          duration: const Duration(milliseconds: 220),
        ),

        CustomRoute(
          page: SignupRoute.page,
          transitionsBuilder: TransitionsBuilders.fadeIn,
          duration: const Duration(milliseconds: 220),
        ),
        CustomRoute(
          page: EmailVerificationRoute.page,
          transitionsBuilder: TransitionsBuilders.fadeIn,
          duration: const Duration(milliseconds: 220),
        ),
        CustomRoute(
          page: FillProfileRoute.page,
          transitionsBuilder: TransitionsBuilders.fadeIn,
          duration: const Duration(milliseconds: 220),
        ),
      ],
    ),

    CustomRoute(
      page: AuthenticatedRoutes.page,
      transitionsBuilder: TransitionsBuilders.fadeIn,
      duration: const Duration(milliseconds: 220),
      children: [
        CustomRoute(
          page: MainRoute.page,
          initial: true,
          transitionsBuilder: TransitionsBuilders.fadeIn,
          duration: const Duration(milliseconds: 220),
          children: [
            CustomRoute(
              page: ConversationsRoute.page,
              transitionsBuilder: TransitionsBuilders.fadeIn,
              duration: const Duration(milliseconds: 220),
            ),
            CustomRoute(
              page: UsersRoute.page,
              transitionsBuilder: TransitionsBuilders.fadeIn,
              duration: const Duration(milliseconds: 220),
            ),
            CustomRoute(
              page: ProfileRoute.page,
              transitionsBuilder: TransitionsBuilders.fadeIn,
              duration: const Duration(milliseconds: 220),
            ),
          ],
        ),
        CustomRoute(
          page: ChatRoute.page,
          transitionsBuilder: TransitionsBuilders.fadeIn,
          duration: const Duration(milliseconds: 220),
        ),
        CustomRoute(
          page: ChatInfoRoute.page,
          transitionsBuilder: TransitionsBuilders.fadeIn,
          duration: const Duration(milliseconds: 220),
        ),
        CustomRoute(
          page: ChatsSettingsRoute.page,
          transitionsBuilder: TransitionsBuilders.fadeIn,
          duration: const Duration(milliseconds: 220),
        ),
        CustomRoute(
          page: LanguageSettingsRoute.page,
          transitionsBuilder: TransitionsBuilders.fadeIn,
          duration: const Duration(milliseconds: 220),
        ),
        CustomRoute(
          page: NotificationSettingsRoute.page,
          transitionsBuilder: TransitionsBuilders.fadeIn,
          duration: const Duration(milliseconds: 220),
        ),
        CustomRoute(
          page: ProfileSettingsRoute.page,
          transitionsBuilder: TransitionsBuilders.fadeIn,
          duration: const Duration(milliseconds: 220),
        ),
        CustomRoute(
          page: AddStoryRoute.page,
          transitionsBuilder: TransitionsBuilders.fadeIn,
          duration: const Duration(milliseconds: 220),
        ),
        CustomRoute(
          page: StoryViewerRoute.page,
          transitionsBuilder: TransitionsBuilders.fadeIn,
          duration: const Duration(milliseconds: 220),
        ),
        CustomRoute(
          page: ChatMediaRoute.page,
          transitionsBuilder: TransitionsBuilders.fadeIn,
          duration: const Duration(milliseconds: 220),
        ),
        CustomRoute(
          page: ChatWallpaperRoute.page,
          transitionsBuilder: TransitionsBuilders.fadeIn,
          duration: const Duration(milliseconds: 220),
        ),
      ],
    ),
  ];
}

@RoutePage(name: 'UnauthenticatedRoutes')
class Unauthenticated extends AutoRouter {
  const Unauthenticated({super.key});
}

@RoutePage(name: 'AuthenticatedRoutes')
class Authenticated extends AutoRouter implements AutoRouteWrapper {
  const Authenticated({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    final uid = context.read<AuthCubit>().state.currentUser?.uid ?? '';

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<ProfileCubit>()..loadProfile(uid: uid),
        ),
        BlocProvider(
          create: (_) => getIt<ConversationsCubit>()..watchChats(uid: uid),
        ),
        BlocProvider(
          create: (_) => getIt<UsersCubit>()..loadUsers(currentUid: uid),
        ),
        BlocProvider(
          create: (_) => getIt<StoriesCubit>()..watchMyStory(uid: uid),
        ),
      ],
      child: this,
    );
  }
}

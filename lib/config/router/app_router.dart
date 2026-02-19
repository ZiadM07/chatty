import 'package:chatty/core/constants/exports.dart';
import 'package:chatty/features/chats/cubits/conversations_cubit.dart';
import 'package:chatty/features/stories/cubits/stories_cubit.dart';
import 'package:chatty/features/users/cubits/users_cubit.dart';
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
    // ── Startup: decides which shell to land on ─────────────────────────
    CustomRoute(
      page: StartupRedirectRoute.page,
      initial: true,
      transitionsBuilder: TransitionsBuilders.fadeIn,
      duration: const Duration(milliseconds: 400),
    ),

    // ── Unauthenticated shell ───────────────────────────────────────────
    CustomRoute(
      page: UnauthenticatedRoutes.page,
      transitionsBuilder: TransitionsBuilders.fadeIn,
      duration: const Duration(milliseconds: 400),
      children: [
        CustomRoute(
          page: WelcomeRoute.page,
          initial: true,
          transitionsBuilder: TransitionsBuilders.fadeIn,
          duration: const Duration(milliseconds: 400),
        ),
        CustomRoute(
          page: LoginRoute.page,
          transitionsBuilder: TransitionsBuilders.fadeIn,
          duration: const Duration(milliseconds: 400),
        ),
        CustomRoute(
          page: SignupRoute.page,
          transitionsBuilder: TransitionsBuilders.fadeIn,
          duration: const Duration(milliseconds: 400),
        ),
        CustomRoute(
          page: FillProfileRoute.page,
          transitionsBuilder: TransitionsBuilders.fadeIn,
          duration: const Duration(milliseconds: 400),
        ),
      ],
    ),

    // ── Authenticated shell ─────────────────────────────────────────────
    CustomRoute(
      page: AuthenticatedRoutes.page,
      transitionsBuilder: TransitionsBuilders.fadeIn,
      duration: const Duration(milliseconds: 400),
      children: [
        CustomRoute(
          page: MainRoute.page,
          initial: true,
          transitionsBuilder: TransitionsBuilders.fadeIn,
          duration: const Duration(milliseconds: 400),
          children: [
            CustomRoute(
              page: ConversationsRoute.page,
              transitionsBuilder: TransitionsBuilders.fadeIn,
              duration: const Duration(milliseconds: 400),
            ),
            CustomRoute(
              page: UsersRoute.page,
              transitionsBuilder: TransitionsBuilders.fadeIn,
              duration: const Duration(milliseconds: 400),
            ),
            CustomRoute(
              page: ProfileRoute.page,
              transitionsBuilder: TransitionsBuilders.fadeIn,
              duration: const Duration(milliseconds: 400),
            ),
          ],
        ),
        CustomRoute(
          page: ChatRoute.page,
          transitionsBuilder: TransitionsBuilders.fadeIn,
          duration: const Duration(milliseconds: 400),
        ),
        CustomRoute(
          page: UserInfoRoute.page,
          transitionsBuilder: TransitionsBuilders.fadeIn,
          duration: const Duration(milliseconds: 400),
        ),
        CustomRoute(
          page: ChatsSettingsRoute.page,
          transitionsBuilder: TransitionsBuilders.fadeIn,
          duration: const Duration(milliseconds: 400),
        ),
        CustomRoute(
          page: LanguageSettingsRoute.page,
          transitionsBuilder: TransitionsBuilders.fadeIn,
          duration: const Duration(milliseconds: 400),
        ),
        CustomRoute(
          page: NotificationSettingsRoute.page,
          transitionsBuilder: TransitionsBuilders.fadeIn,
          duration: const Duration(milliseconds: 400),
        ),
        CustomRoute(
          page: ProfileSettingsRoute.page,
          transitionsBuilder: TransitionsBuilders.fadeIn,
          duration: const Duration(milliseconds: 400),
        ),
        CustomRoute(
          page: AddStoryRoute.page,
          transitionsBuilder: TransitionsBuilders.fadeIn,
          duration: const Duration(milliseconds: 400),
        ),
        CustomRoute(
          page: StoryViewerRoute.page,
          transitionsBuilder: TransitionsBuilders.fadeIn,
          duration: const Duration(milliseconds: 400),
        ),
        CustomRoute(
          page: MediaRoute.page,
          transitionsBuilder: TransitionsBuilders.fadeIn,
          duration: const Duration(milliseconds: 400),
        ),
           CustomRoute(
          page: ChatWallpaperRoute.page,
          transitionsBuilder: TransitionsBuilders.fadeIn,
          duration: const Duration(milliseconds: 400),
        ),
      ],
    ),
  ];
}

// ─── Shell wrappers ───────────────────────────────────────────────────────────

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
        // ── Profile ────────────────────────────────────────────────────────
        // Loaded once, shared across all authenticated screens.
        BlocProvider(
          create: (_) => getIt<ProfileCubit>()..loadProfile(uid: uid),
        ),

        // ── Conversations ──────────────────────────────────────────────────
        // Persistent real-time stream of all chats.
        // Lives here so the unread badge on the tab bar always stays updated
        // even when the user is on a different tab.
        BlocProvider(
          create: (_) => getIt<ConversationsCubit>()..watchChats(uid: uid),
        ),

        // ── Users ──────────────────────────────────────────────────────────
        // First page loaded here so the users tab is instant on first visit.
        BlocProvider(
          create: (_) => getIt<UsersCubit>()..loadUsers(currentUid: uid),
        ),

        // ── Stories ────────────────────────────────────────────────────────
        // My story + feed stories streamed here so the rings row and
        // "My Story" avatar stay live on any tab.
        // Feed contacts are seeded from the chats list via ConversationsCubit
        // in the conversations screen once chats are loaded.
        BlocProvider(
          create: (_) => getIt<StoriesCubit>()..watchMyStory(uid: uid),
        ),
      ],
      child: this,
    );
  }
}

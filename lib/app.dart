import 'package:Chatty/route_observer.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/constants/exports.dart';
import 'core/di/injectable.dart';
import 'features/auth/cubits/auth_cubit.dart';
import 'features/shared/cubits/app_cubit.dart';
import 'l10n/app_localizations.dart';

class ChattyApp extends StatefulWidget {
  static late AppLocalizations locale;
  static late bool isDarkTheme;
  static late bool isArabic;
  static late BuildContext context;

  const ChattyApp({super.key});

  @override
  State<ChattyApp> createState() => _ChattyAppState();
}

class _ChattyAppState extends State<ChattyApp> with WidgetsBindingObserver {
  late final AppCubit _appCubit;
  late final AuthCubit _authCubit;
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _appCubit = getIt<AppCubit>();
    _authCubit = getIt<AuthCubit>();
    _appRouter = AppRouter(getIt<AppPreferences>());
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangePlatformBrightness() {
    _appCubit.applyPlatformThemeMode();
    super.didChangePlatformBrightness();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        _authCubit.setOnline();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _authCubit.setOffline();
        break;
      case AppLifecycleState.inactive:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AppCubit>(create: (_) => _appCubit),
        BlocProvider<AuthCubit>(create: (_) => _authCubit),
      ],
      child: ResponsiveWrapper(
        child: BlocBuilder<AppCubit, AppState>(
          builder: (context, state) {
            final cubit = context.read<AppCubit>();
            ChattyApp.isDarkTheme = cubit.appThemeMode.isDarkTheme;

            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              theme: cubit.appThemeMode.data,
              routerConfig: _appRouter.config(
                navigatorObservers: () => [
                  MyRouteObserver(),
                  AutoRouteObserver(),
                ],
              ),
              onGenerateTitle: (context) {
                ChattyApp.locale = AppLocalizations.of(context)!;
                ChattyApp.isArabic = cubit.locale.languageCode == 'ar';
                return '';
              },
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              locale: cubit.locale,
            );
          },
        ),
      ),
    );
  }
}

import 'package:Chatty/config/router/app_router.gr.dart';
import 'package:Chatty/core/constants/exports.dart';
import 'package:Chatty/features/auth/cubits/auth_cubit.dart';
import 'package:Chatty/features/auth/cubits/auth_state.dart';
import 'package:Chatty/features/auth/ui/widgets/splash_background_particles.dart';
import 'package:Chatty/features/auth/ui/widgets/splash_loading_indicator.dart';
import 'package:Chatty/features/auth/ui/widgets/splash_logo.dart';
import 'package:Chatty/features/auth/ui/widgets/splash_tagline.dart';

@RoutePage()
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _pulseController;
  late AnimationController _particleController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<Offset> _logoSlide;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _textController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolveAuth());
  }

  Future<void> _resolveAuth() async {
    if (!mounted) return;
    final cubit = context.read<AuthCubit>();
    final AuthState state;

    if (cubit.state.authReady) {
      state = cubit.state;
    } else {
      state = await cubit.stream.first;
    }

    await Future.delayed(const Duration(milliseconds: 3200));
    _redirect(state);
  }

  void _redirect(AuthState state) {
    if (!mounted) return;
    final user = state.currentUser;

    if (user == null) {
      context.router.replaceAll([const UnauthenticatedRoutes()]);
      return;
    }

    if (user.needsProfileSetup) {
      context.router.replaceAll([
        UnauthenticatedRoutes(children: [const FillProfileRoute()]),
      ]);
      return;
    }

    context.router.replaceAll([const AuthenticatedRoutes()]);
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0, 0.5, curve: Curves.easeOut),
      ),
    );

    _logoSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _logoController, curve: Curves.easeOutCubic),
        );

    _textOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    _textSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
        );

    _pulseScale = Tween<double>(begin: 0.97, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          SplashBackgroundParticles(controller: _particleController),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              SplashLogo(
                logoScale: _logoScale,
                logoOpacity: _logoOpacity,
                logoSlide: _logoSlide,
                pulseScale: _pulseScale,
              ),

              const SizedBox(height: 36),

              SplashTagline(textOpacity: _textOpacity, textSlide: _textSlide),

              const Spacer(flex: 2),

              SplashLoadingIndicator(
                opacity: _textOpacity,
                color: context.colorScheme.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

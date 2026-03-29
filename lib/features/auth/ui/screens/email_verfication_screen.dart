import 'dart:async';

import 'package:Chatty/config/router/app_router.gr.dart';
import 'package:Chatty/core/constants/exports.dart';
import 'package:Chatty/features/auth/cubits/auth_cubit.dart';
import 'package:Chatty/features/auth/cubits/auth_state.dart';
import 'package:Chatty/features/shared/widgets/app_toast.dart';

@RoutePage()
class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  Timer? _pollTimer;
  bool _canResend = false;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    _startPolling();
    _startCooldown();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      final verified = await context.read<AuthCubit>().checkEmailVerified();
      if (verified && mounted) {
        _pollTimer?.cancel();
        context.router.replace(const FillProfileRoute());
      }
    });
  }

  void _startCooldown() {
    setState(() {
      _canResend = false;
      _resendCooldown = 30;
    });
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown <= 1) {
        timer.cancel();
        if (mounted) setState(() => _canResend = true);
      } else {
        if (mounted) setState(() => _resendCooldown--);
      }
    });
  }

  void _resend() {
    if (!_canResend) return;
    context.read<AuthCubit>().sendEmailVerification();
    _startCooldown();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (prev, curr) =>
          prev.emailVerificationState != curr.emailVerificationState,
      listener: (context, state) {
        if (state.emailVerificationState.status == StateStatus.success) {
          context.read<AuthCubit>().resetEmailVerificationState();
          AppToast.showSuccess(
            message:
                state.emailVerificationState.message ??
                context.locale.emailVerificationSent,
            context: context,
          );
        }
        if (state.emailVerificationState.status == StateStatus.error) {
          context.read<AuthCubit>().resetEmailVerificationState();
          AppToast.showError(
            message:
                state.emailVerificationState.message ??
                context.locale.emailVerificationFailed,
            context: context,
          );
        }
      },
      child: AppScaffold(
        showAppBar: false,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        context.colorScheme.primary.withValues(alpha: 0.15),
                        context.colorScheme.secondary.withValues(alpha: 0.15),
                      ],
                    ),
                  ),
                  child: Icon(
                    Icons.mark_email_unread_rounded,
                    size: 64,
                    color: context.colorScheme.primary,
                  ),
                ),

                const SizedBox(height: 32),

                AppText(
                  context.locale.verifyEmailTitle,
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 16),

                AppText(
                  context.locale.verifyEmailDescription,
                  align: TextAlign.center,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.textSecondary,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _canResend ? _resend : null,
                    icon: const Icon(Icons.refresh_rounded),
                    label: AppText(
                      _canResend
                          ? context.locale.resendVerification
                          : context.locale.resendIn(_resendCooldown),
                      style: context.textTheme.labelLarge?.copyWith(
                        color: _canResend
                            ? context.colorScheme.onPrimary
                            : context.colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: context.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: context.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      AppText(
                        context.locale.waitingForVerification,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                TextButton(
                  onPressed: () async {
                    await context.read<AuthCubit>().signOut();
                    if (context.mounted) {
                      context.router.maybePop();
                    }
                  },
                  child: AppText(
                    context.locale.backToLogin,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

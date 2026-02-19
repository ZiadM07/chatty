import 'package:chatty/config/router/app_router.gr.dart';
import 'package:chatty/features/auth/cubits/auth_cubit.dart';
import 'package:chatty/features/auth/cubits/auth_state.dart';
import 'package:chatty/features/shared/widgets/app_asset_image.dart';
import 'package:chatty/features/shared/widgets/app_gradient_button.dart';
import 'package:chatty/features/shared/widgets/app_text_form_field.dart';
import '../../../../core/constants/exports.dart';
import '../../../shared/widgets/app_toast.dart';

@RoutePage()
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  // ─── Submit ───────────────────────────────────────────────────────────────

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );
  }

  // ─── Navigation ───────────────────────────────────────────────────────────

  void _onSuccess(AuthState state) {
    context.read<AuthCubit>().resetLoginState();

    final user = state.currentUser;
    if (user == null) return;

    if (user.needsProfileSetup) {
      context.router.push(const FillProfileRoute());
    } else {
      context.router.replaceAll([const AuthenticatedRoutes()]);
    }
  }

  void _onFailure(AuthState state) {
    context.read<AuthCubit>().resetLoginState();
    AppToast.showError(
      message: state.loginState.message ?? context.locale.unexpectedError,
      context: context,
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      // Only rebuild when loginState changes — nothing else matters here
      buildWhen: (prev, curr) => prev.loginState != curr.loginState,
      listenWhen: (prev, curr) => prev.loginState != curr.loginState,
      listener: (context, state) {
        if (state.loginState.status == StateStatus.success) _onSuccess(state);
        if (state.loginState.status == StateStatus.error) _onFailure(state);
      },
      builder: (context, state) {
        return StateHandler(
          state: state.loginState,
          builder: (context, state) => AppScaffold(
            appbarSize: 0,
            showBackButton: false,
            body: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 50),

                    Align(
                      alignment: Alignment.center,
                      child: AppAssetImage(
                        Pngs.chatty,
                        fit: BoxFit.contain,
                        width: 200,
                        height: 100,
                      ),
                    ),

                    const SizedBox(height: 50),

                    AppTextFormField(
                      controller: _emailController,
                      borderColor: context.colorScheme.border.withValues(
                        alpha: 0.5,
                      ),
                      label: context.locale.email,
                      hintText: context.locale.email,
                      borderWidth: 1,
                      borderRadius: 12,
                      textInputType: TextInputType.emailAddress,
                      validator: Validator.validateEmail,
                      focusNode: _emailFocusNode,
                      onFieldSubmitted: (_) =>
                          _passwordFocusNode.requestFocus(),
                    ),

                    const SizedBox(height: 10),

                    AppTextFormField(
                      controller: _passwordController,
                      borderColor: context.colorScheme.border.withValues(
                        alpha: 0.5,
                      ),
                      label: context.locale.password,
                      hintText: context.locale.password,
                      borderWidth: 1,
                      borderRadius: 12,
                      validator: Validator.validatePassword,
                      isPasswordField: true,
                      focusNode: _passwordFocusNode,
                      onFieldSubmitted: (_) => _submit(),
                    ),

                    const SizedBox(height: 40),

                    AppButton(text: context.locale.login, onTap: _submit),

                    const SizedBox(height: 30),

                    Divider(
                      color: context.colorScheme.outline,
                      height: 1,
                      thickness: 1,
                    ),

                    const SizedBox(height: 30),

                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "${context.locale.byLoggingInYouAgree} ",
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colorScheme.textPrimary,
                            ),
                          ),
                          TextSpan(
                            text: "${context.locale.termsAndConditions} ",
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(
                            text: "${context.locale.and} ",
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colorScheme.textPrimary,
                            ),
                          ),
                          TextSpan(
                            text: context.locale.privacyPolicy,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 50),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppText(
                          context.locale.dontHaveAccount,
                          style: context.textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: () =>
                              context.router.push(const SignupRoute()),
                          child: AppText(
                            context.locale.signup,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ).addPadding(horizontal: 20),
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'package:Chatty/features/auth/cubits/auth_cubit.dart';
import 'package:Chatty/features/auth/cubits/auth_state.dart';
import 'package:Chatty/features/shared/widgets/app_asset_image.dart';
import 'package:Chatty/features/shared/widgets/app_gradient_button.dart';
import 'package:Chatty/features/shared/widgets/app_text_form_field.dart';
import 'package:Chatty/config/router/app_router.gr.dart';
import 'package:Chatty/features/shared/widgets/app_toast.dart';
import '../../../../core/constants/exports.dart';

@RoutePage()
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );
  }

  void _onSuccess() {
    context.read<AuthCubit>().resetSignUpState();
    context.router.push(const EmailVerificationRoute());
  }

  void _onFailure(AuthState state) {
    context.read<AuthCubit>().resetSignUpState();
    AppToast.showError(
      message: context.locale.thisOperationFailed,
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      buildWhen: (prev, curr) => prev.signUpState != curr.signUpState,
      listenWhen: (prev, curr) => prev.signUpState != curr.signUpState,
      listener: (context, state) {
        if (state.signUpState.status == StateStatus.success) _onSuccess();
        if (state.signUpState.status == StateStatus.error) _onFailure(state);
      },
      builder: (context, state) {
        return StateHandler(
          state: state.signUpState,
          loadingWidget: const AppScaffold(
            showAppBar: false,
            body: Center(child: CircularProgressIndicator()),
          ),
          builder: (context, _) => AppScaffold(
            showAppBar: false,
            body: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 80),

                    Align(
                      alignment: Alignment.center,
                      child: AppAssetImage(
                        Pngs.chatty,
                        fit: BoxFit.contain,
                        width: 200,
                        height: 80,
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
                      textInputType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: Validator.validateEmail,
                      focusNode: _emailFocusNode,
                      onFieldSubmitted: (_) =>
                          _passwordFocusNode.requestFocus(),
                    ),

                    const SizedBox(height: 10),

                    AppTextFormField(
                      controller: _passwordController,
                      label: context.locale.password,
                      hintText: context.locale.password,
                      validator: Validator.validatePassword,
                      isPasswordField: true,
                      textInputAction: TextInputAction.next,
                      focusNode: _passwordFocusNode,
                      onFieldSubmitted: (_) =>
                          _confirmPasswordFocusNode.requestFocus(),
                    ),

                    const SizedBox(height: 10),

                    AppTextFormField(
                      controller: _confirmPasswordController,
                      label: context.locale.confirmYourPassword,
                      hintText: context.locale.confirmYourPassword,
                      validator: (v) => Validator.validateConfirmPassword(
                        _passwordController.text.trim(),
                        v?.trim(),
                      ),
                      isPasswordField: true,
                      textInputAction: TextInputAction.done,
                      focusNode: _confirmPasswordFocusNode,
                      onFieldSubmitted: (_) => _submit(),
                    ),

                    const SizedBox(height: 40),

                    AppButton(text: context.locale.signup, onTap: _submit),

                    const SizedBox(height: 30),

                    Divider(color: context.colorScheme.outline, height: 1),

                    const SizedBox(height: 30),

                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "${context.locale.bySigningUpYouAgree} ",
                            style: context.textTheme.bodyMedium,
                          ),
                          TextSpan(
                            text: "${context.locale.termsAndConditions} ",
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
                      children: [
                        AppText(
                          context.locale.alreadyHaveAccount,
                          style: context.textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: () => context.router.maybePop(),
                          child: AppText(
                            context.locale.login,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 50),
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

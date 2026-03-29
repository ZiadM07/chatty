import 'package:Chatty/features/auth/cubits/auth_cubit.dart';
import 'package:Chatty/features/auth/cubits/auth_state.dart';
import 'package:Chatty/features/shared/widgets/app_asset_image.dart';
import 'package:Chatty/features/shared/widgets/app_gradient_button.dart';
import 'package:Chatty/features/shared/widgets/app_text_form_field.dart';
import 'package:Chatty/features/shared/widgets/app_toast.dart';
import '../../../../core/constants/exports.dart';

@RoutePage()
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().sendPasswordResetEmail(
      email: _emailController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listenWhen: (prev, curr) =>
          prev.forgotPasswordState != curr.forgotPasswordState,
      buildWhen: (prev, curr) =>
          prev.forgotPasswordState != curr.forgotPasswordState,
      listener: (context, state) {
        if (state.forgotPasswordState.isSuccess) {
          context.read<AuthCubit>().resetForgotPasswordState();
          AppToast.showSuccess(
            message: context.locale.resetLinkSent,
            context: context,
          );
          context.router.maybePop();
        }
        if (state.forgotPasswordState.isError) {
          context.read<AuthCubit>().resetForgotPasswordState();
          AppToast.showError(
            message:
                state.forgotPasswordState.message ??
                context.locale.thisOperationFailed,
            context: context,
          );
        }
      },
      builder: (context, state) {
        return StateHandler(
          state: state.forgotPasswordState,
          builder: (context, _) => AppScaffold(
            showAppBar: false,
            body: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 80),

                    Align(
                      alignment: Alignment.center,
                      child: AppAssetImage(
                        Pngs.chatty,
                        fit: BoxFit.contain,
                        width: 200,
                        height: 100,
                      ),
                    ),

                    const SizedBox(height: 60),

                    AppText(
                      context.locale.forgotPassword,
                      style: context.textTheme.titleLarge,
                      align: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    AppText(
                      context.locale.forgotPasswordSubtitle,
                      style: context.textTheme.bodyMedium,
                      align: TextAlign.center,
                    ),

                    const SizedBox(height: 40),

                    AppTextFormField(
                      controller: _emailController,
                      label: context.locale.email,
                      hintText: context.locale.email,
                      textInputType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      validator: Validator.validateEmail,
                      focusNode: _emailFocusNode,
                      onFieldSubmitted: (_) => _submit(),
                      borderColor: context.colorScheme.border.withValues(
                        alpha: 0.5,
                      ),
                    ),

                    const SizedBox(height: 40),

                    AppButton(
                      text: context.locale.sendResetLink,
                      onTap: _submit,
                    ),

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppText(
                          "${context.locale.backTo} ",
                          style: context.textTheme.bodyMedium,
                        ),
                        AppText(
                          context.locale.login,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ).addAction(onTap: () => context.router.maybePop()),
                      ],
                    ),

                    const SizedBox(height: 50),
                  ],
                ).addPadding(horizontal: 24),
              ),
            ),
          ),
        );
      },
    );
  }
}

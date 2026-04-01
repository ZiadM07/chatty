import 'package:Chatty/core/constants/exports.dart';
import 'package:Chatty/features/profile/cubits/profile_cubit.dart';
import 'package:Chatty/features/profile/cubits/profile_state.dart';
import 'package:Chatty/features/shared/widgets/app_gradient_button.dart';
import 'package:Chatty/features/shared/widgets/app_text_form_field.dart';
import 'package:Chatty/features/shared/widgets/app_toast.dart';

@RoutePage()
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _currentPasswordFocus = FocusNode();
  final _newPasswordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _currentPasswordFocus.dispose();
    _newPasswordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<ProfileCubit>().changePassword(
      currentPassword: _currentPasswordController.text.trim(),
      newPassword: _newPasswordController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listenWhen: (prev, curr) =>
          prev.changePasswordState != curr.changePasswordState,
      buildWhen: (prev, curr) =>
          prev.changePasswordState != curr.changePasswordState,
      listener: (context, state) {
        if (state.changePasswordState.status == StateStatus.success) {
          context.read<ProfileCubit>().resetChangePasswordState();
          AppToast.showSuccess(
            message:
                state.changePasswordState.message ??
                context.locale.passwordChangedSuccess,
            context: context,
          );
          context.router.maybePop();
        }
        if (state.changePasswordState.status == StateStatus.error) {
          context.read<ProfileCubit>().resetChangePasswordState();
          AppToast.showError(
            message:
                state.changePasswordState.message ??
                context.locale.unexpectedError,
            context: context,
          );
        }
      },
      builder: (context, state) {
        final isLoading = state.changePasswordState.isLoading;

        return StateHandler(
          state: state.changePasswordState,
          builder: (context, _) => AppScaffold(
            showBackButton: true,
            title: context.locale.changePassword,
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),

                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              context.colorScheme.primary,
                              context.colorScheme.secondary,
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: context.colorScheme.primary.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          SolarIconsOutline.lockKeyholeMinimalistic,
                          color: context.colorScheme.onPrimary,
                          size: 48,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Center(
                      child: AppText(
                        context.locale.changePasswordSubtitle,
                        align: TextAlign.center,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    AppText(
                      context.locale.currentPassword,
                      style: context.textTheme.labelLarge?.copyWith(
                        color: context.colorScheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AppTextFormField(
                      controller: _currentPasswordController,
                      hintText: context.locale.enterCurrentPassword,
                      isPasswordField: true,
                      borderRadius: 12,
                      borderWidth: 1,
                      borderColor: context.colorScheme.outline.withValues(
                        alpha: 0.4,
                      ),
                      textInputAction: TextInputAction.next,
                      focusNode: _currentPasswordFocus,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return context.locale.currentPasswordRequired;
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => _newPasswordFocus.requestFocus(),
                    ),

                    const SizedBox(height: 20),

                    Divider(
                      color: context.colorScheme.outline.withValues(alpha: 0.2),
                    ),

                    const SizedBox(height: 20),

                    AppText(
                      context.locale.newPassword,
                      style: context.textTheme.labelLarge?.copyWith(
                        color: context.colorScheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AppTextFormField(
                      controller: _newPasswordController,
                      hintText: context.locale.enterNewPassword,
                      isPasswordField: true,
                      borderRadius: 12,
                      borderWidth: 1,
                      borderColor: context.colorScheme.outline.withValues(
                        alpha: 0.4,
                      ),
                      textInputAction: TextInputAction.next,
                      focusNode: _newPasswordFocus,
                      validator: (v) {
                        final base = Validator.validatePassword(v);
                        if (base != null) return base;
                        if (v?.trim() ==
                            _currentPasswordController.text.trim()) {
                          return context.locale.newPasswordMustBeDifferent;
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) =>
                          _confirmPasswordFocus.requestFocus(),
                    ),

                    const SizedBox(height: 20),

                    AppText(
                      context.locale.confirmNewPassword,
                      style: context.textTheme.labelLarge?.copyWith(
                        color: context.colorScheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AppTextFormField(
                      controller: _confirmPasswordController,
                      hintText: context.locale.confirmNewPasswordHint,
                      isPasswordField: true,
                      borderRadius: 12,
                      borderWidth: 1,
                      borderColor: context.colorScheme.outline.withValues(
                        alpha: 0.4,
                      ),
                      textInputAction: TextInputAction.done,
                      focusNode: _confirmPasswordFocus,
                      validator: (v) => Validator.validateConfirmPassword(
                        _newPasswordController.text.trim(),
                        v?.trim(),
                      ),
                      onFieldSubmitted: (_) => _submit(),
                    ),

                    const SizedBox(height: 36),

                    AppButton(
                      text: isLoading
                          ? context.locale.loading
                          : context.locale.changePassword,
                      onTap: isLoading ? null : _submit,
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

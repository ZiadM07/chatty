// lib/features/profile/ui/widgets/show_delete_account_sheet.dart

import 'package:Chatty/config/router/app_router.gr.dart';
import 'package:Chatty/core/constants/exports.dart';
import 'package:Chatty/features/auth/cubits/auth_cubit.dart';
import 'package:Chatty/features/auth/cubits/auth_state.dart';
import 'package:Chatty/features/shared/widgets/app_gradient_button.dart';
import 'package:Chatty/features/shared/widgets/app_text_form_field.dart';
import 'package:Chatty/features/shared/widgets/app_toast.dart';

class DeleteAccountSheet extends StatefulWidget {
  const DeleteAccountSheet({super.key});

  @override
  State<DeleteAccountSheet> createState() => _DeleteAccountSheetState();
}

class _DeleteAccountSheetState extends State<DeleteAccountSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirm() {
    final password = _controller.text.trim();
    if (password.isEmpty) return;
    context.read<AuthCubit>().deleteAccount(password: password);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (prev, curr) => prev.signOutState != curr.signOutState,
      listener: (context, state) {
        if (state.signOutState.status == StateStatus.success) {
          context.router.replaceAll([const UnauthenticatedRoutes()]);
          AppToast.showSuccess(
            message: context.locale.deleteAccountSuccess,
            context: context,
          );

          return;
        }
        if (state.signOutState.status == StateStatus.error) {
          context.router.pop();
          AppToast.showError(
            message: context.locale.deleteAccountFailed,
            context: context,
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              context.locale.deleteAccountSubtitle,
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            AppText(
              context.locale.deleteAccountConfirm,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            AppTextFormField(
              controller: _controller,
              hintText: context.locale.password,
              obscureText: true,
              borderRadius: 12,
              borderWidth: 1,
              isPasswordField: true,
              borderColor: context.colorScheme.outline.withValues(alpha: 0.4),
              onFieldSubmitted: (_) => _confirm(),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: context.locale.cancel,
                    type: AppButtonType.normal,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onPrimary,
                    ),
                  ).addAction(onTap: () => context.router.pop()),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    text: context.locale.deleteAccount,
                    type: AppButtonType.error,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onPrimary,
                    ),
                    onTap: _confirm,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

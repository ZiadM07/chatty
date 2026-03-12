import 'package:Chatty/core/constants/exports.dart';
import 'package:Chatty/features/chats/cubits/chat_cubit.dart';
import 'package:Chatty/features/shared/widgets/app_gradient_button.dart';
import 'package:Chatty/features/shared/widgets/app_toast.dart';

void confirmDeleteMessage({
  required BuildContext context,
  required String messageId,
}) {
  final chatCubit = context.read<ChatCubit>();

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) {
      return BlocProvider.value(
        value: chatCubit,
        child: BlocConsumer<ChatCubit, ChatState>(
          listenWhen: (prev, curr) =>
              prev.deleteMessageState != curr.deleteMessageState,
          listener: (ctx, state) {
            if (state.deleteMessageState.status == StateStatus.success) {
              ctx.router.pop();
            }
            if (state.deleteMessageState.status == StateStatus.error) {
              ctx.router.pop();
              AppToast.showError(
                message: context.locale.thisOperationFailed,

                context: context,
              );
            }
          },
          builder: (ctx, state) {
            return StateHandler(
              state: state.deleteMessageState,
              loadingOverlayWidget: const CircularProgressIndicator(),
              builder: (ctx, _) => _DeleteMessageSheetContent(
                chatCubit: chatCubit,
                messageId: messageId,
              ),
            );
          },
        ),
      );
    },
  );
}

class _DeleteMessageSheetContent extends StatelessWidget {
  final ChatCubit chatCubit;
  final String messageId;

  const _DeleteMessageSheetContent({
    required this.chatCubit,
    required this.messageId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.colorScheme.error,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  SolarIconsOutline.trashBinTrash,
                  color: context.colorScheme.onPrimary,
                  size: 28,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                context.locale.deleteMessage,
                style: context.textTheme.titleLarge?.copyWith(
                  color: context.colorScheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                context.locale.deleteMessageConfirm,
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.textSecondary,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 28),

              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: context.colorScheme.surfaceContainerHighest,
                      ),
                      child: Center(
                        child: AppText(
                          context.locale.cancel,
                          style: context.textTheme.bodyMedium,
                        ),
                      ),
                    ).addAction(onTap: () => context.router.pop()),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: AppButton(
                      text: context.locale.delete,
                      type: AppButtonType.error,
                      style: context.textTheme.titleMedium?.copyWith(
                        color: context.colorScheme.textPrimary,
                      ),
                      onTap: () {
                        chatCubit.deleteMessage(messageId: messageId);
                        context.router.pop();
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

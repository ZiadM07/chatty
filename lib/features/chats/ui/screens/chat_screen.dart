import 'package:chatty/core/constants/exports.dart';
import 'package:chatty/features/auth/cubits/auth_cubit.dart';
import 'package:chatty/features/chats/cubits/chat_cubit.dart';
import 'package:chatty/features/chats/ui/widgets/chat_app_bar.dart';
import 'package:chatty/features/chats/ui/widgets/chat_back_ground.dart';
import 'package:chatty/features/chats/ui/widgets/chat_input.dart';
import 'package:chatty/features/chats/ui/widgets/swipe_to_reply.dart';
import 'package:chatty/features/chats/ui/widgets/text_message_bubble.dart';
import '../../../../core/di/injectable.dart';
import '../../../../core/utils/enums.dart';
import '../../../shared/widgets/app_toast.dart';
import '../widgets/voice_message_bubble.dart';

@RoutePage()
class ChatScreen extends StatefulWidget implements AutoRouteWrapper {
  final String chatId;
  const ChatScreen({super.key, required this.chatId});

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider(create: (_) => getIt<ChatCubit>(), child: this);
  }

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final String _currentUid;

  @override
  void initState() {
    super.initState();
    _currentUid = context.read<AuthCubit>().state.currentUser?.uid ?? '';
    context.read<ChatCubit>().init(
      chatId: widget.chatId,
      currentUid: _currentUid,
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSendAttachment(File file) {
    final ext = file.path.split('.').last.toLowerCase();
    final type = switch (ext) {
      'jpg' || 'jpeg' || 'png' || 'webp' || 'gif' => MessageType.image,
      'mp4' || 'mov' || 'avi' => MessageType.video,
      'mp3' || 'aac' || 'm4a' || 'wav' => MessageType.audio,
      _ => MessageType.file,
    };
    context.read<ChatCubit>().sendMediaMessage(
      senderId: _currentUid,
      file: file,
      type: type,
    );
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatCubit, ChatState>(
      listenWhen: (prev, curr) => prev.sendState != curr.sendState,
      listener: (context, state) {
        if (state.sendState.status == StateStatus.error) {
          context.read<ChatCubit>().resetSendState();
          AppToast.showError(
            message: state.sendState.message ?? context.locale.unexpectedError,
            context: context,
          );
        }
      },
      child: BlocBuilder<ChatCubit, ChatState>(
        builder: (context, state) {
          return AppScaffold(
            showBackButton: false,
            appbarSize: 0,
            body: ChatBackGround(
              child: Stack(
                children: [
                  CustomScrollView(
                    slivers: [
                      ChatAppBar(chat: state.chat),
                      SliverFillRemaining(
                        hasScrollBody: true,
                        child: _buildBody(context, state),
                      ),
                    ],
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 24,
                    child: ChatInput(
                      focusNode: _focusNode,
                      controller: _controller,
                      hintText: context.locale.typeMessage,
                      isSendingMedia:
                          state.sendState.status == StateStatus.loadingOverlay,
                      replyingTo: state.replyingTo,
                      currentUid: _currentUid,
                      onCancelReply: () =>
                          context.read<ChatCubit>().clearReplyingTo(),
                      onSendPressed: (text) {
                        context.read<ChatCubit>().sendTextMessage(
                          senderId: _currentUid,
                          content: text,
                        );
                        _scrollToBottom();
                      },
                      onTextChanged: (_) {},
                      onSendAttachment: _onSendAttachment,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, ChatState state) {
    if (state.chatState.status == StateStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.chatState.status == StateStatus.error) {
      return Center(
        child: AppText(
          state.chatState.message ?? context.locale.unexpectedError,
          style: context.textTheme.bodyMedium,
        ),
      );
    }

    final messages = state.messagesState.data ?? [];

    if (messages.isEmpty && state.messagesState.status == StateStatus.success) {
      return Center(
        child: AppText(
          context.locale.noMessagesYet,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.textSecondary,
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 85),
      reverse: true,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[messages.length - 1 - index];
        final isMe = message.senderId == _currentUid;

        // Find the last message sent by me (index 0 in reversed list = latest overall)
        // Show status only on that one message
        final lastMyMessageIndex = messages.lastIndexWhere(
          (m) => m.senderId == _currentUid,
        );
        final isLastMyMessage =
            messages.length - 1 - index == lastMyMessageIndex;

        return SwipeToReply(
          isMe: isMe,
          onSwipe: message.isDeleted
              ? null
              : () => context.read<ChatCubit>().setReplyingTo(message),
          onLongPress: isMe && !message.isDeleted
              ? () => context.read<ChatCubit>().deleteMessage(
                  messageId: message.id,
                )
              : null,
          child: message.type == MessageType.audio
              ? VoiceMessageBubble(
                  audioUrl: message.content,
                  duration: Duration(
                    milliseconds: message.metadata?['duration'] as int? ?? 0,
                  ),
                  time: _formatTime(message.createdAt),
                  status: isMe && isLastMyMessage ? message.status : null,
                  isMe: isMe,
                  isDeleted: message.isDeleted,
                  currentUid: _currentUid,
                )
              : TextMessageBubble(
                  message: message.isDeleted
                      ? context.locale.messageDeleted
                      : message.content,
                  time: _formatTime(message.createdAt),
                  status: isMe && isLastMyMessage ? message.status : null,
                  isMe: isMe,
                  isDeleted: message.isDeleted,
                  messageType: message.type,
                  replyToContent: message.replyToContent,
                  replyToSenderId: message.replyToSenderId,
                  currentUid: _currentUid,
                ),
        );
      },
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12
        ? dt.hour - 12
        : dt.hour == 0
        ? 12
        : dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}

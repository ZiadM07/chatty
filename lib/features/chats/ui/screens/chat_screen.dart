import 'package:Chatty/core/constants/exports.dart';
import 'package:Chatty/features/auth/cubits/auth_cubit.dart';
import 'package:Chatty/features/chats/cubits/chat_cubit.dart';
import 'package:Chatty/features/chats/data/models/message_model.dart';
import 'package:Chatty/features/chats/ui/widgets/chat_app_bar.dart';
import 'package:Chatty/features/chats/ui/widgets/chat_back_ground.dart';
import 'package:Chatty/features/chats/ui/widgets/chat_input.dart';
import 'package:Chatty/features/chats/ui/widgets/confirm_delete_message.dart';
import 'package:Chatty/features/chats/ui/widgets/swipe_to_reply.dart';
import 'package:Chatty/features/chats/ui/widgets/text_message_bubble.dart';
import 'package:Chatty/features/chats/ui/widgets/media_message_bubble.dart';
import '../../../../core/di/injectable.dart';
import '../../../../core/utils/enums.dart';
import '../../../shared/widgets/app_loading.dart';
import '../../../shared/widgets/app_toast.dart';
import '../widgets/voice_message_bubble.dart';

@RoutePage()
class ChatScreen extends StatefulWidget implements AutoRouteWrapper {
  final String chatId;
  const ChatScreen({super.key, required this.chatId});

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider(create: (context) => getIt<ChatCubit>(), child: this);
  }

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<bool> _showFab = ValueNotifier(false);
  final ValueNotifier<String?> _highlightedMessageId = ValueNotifier(null);
  final Map<String, GlobalKey> _messageKeys = {};
  late final String _currentUid;

  @override
  void initState() {
    super.initState();
    _currentUid = context.read<AuthCubit>().state.currentUser?.uid ?? '';
    context.read<ChatCubit>().init(
      chatId: widget.chatId,
      currentUid: _currentUid,
    );
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final offset = _scrollController.offset;

    final shouldShowFab = offset >= 400;
    if (_showFab.value != shouldShowFab) _showFab.value = shouldShowFab;

    final cubit = context.read<ChatCubit>();
    if (offset <= 80) {
      cubit.onScrolledToBottom();
    } else {
      cubit.onScrolledAway();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _showFab.dispose();
    _highlightedMessageId.dispose();
    _messageKeys.clear();
    _focusNode.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _scrollToMessage(String messageId) async {
    final messages = context.read<ChatCubit>().state.messagesState.data ?? [];
    final listIndex = messages.indexWhere((m) => m.id == messageId);
    if (listIndex == -1) return;
    final scrollIndex = messages.length - 1 - listIndex;
    final maxExtent = _scrollController.position.maxScrollExtent;
    const roughItemHeight = 80.0;
    final roughOffset = (scrollIndex * roughItemHeight).clamp(0.0, maxExtent);

    await _scrollController.animateTo(
      roughOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );

    await Future.delayed(const Duration(milliseconds: 50));
    if (!mounted) return;

    final key = _messageKeys[messageId];
    final itemContext = key?.currentContext;
    if (itemContext != null && context.mounted) {
      await Scrollable.ensureVisible(
        itemContext,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        alignment: 0.5,
      );
    }

    if (!mounted) return;
    _highlightedMessageId.value = messageId;
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) _highlightedMessageId.value = null;
    });
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
    return BlocConsumer<ChatCubit, ChatState>(
      listenWhen: (prev, curr) => prev.sendState != curr.sendState,
      listener: (context, state) {
        if (state.sendState.status == StateStatus.error) {
          context.read<ChatCubit>().resetSendState();
          AppToast.showError(
            message: context.locale.thisOperationFailed,
            context: context,
          );
        }
      },
      builder: (context, state) {
        final messages = state.messagesState.data ?? [];

        return AppScaffold(
          showAppBar: false,

          floatingActionButton: ValueListenableBuilder<bool>(
            valueListenable: _showFab,
            builder: (context, show, _) {
              if (!show) return const SizedBox.shrink();
              return Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      context.colorScheme.primary.withValues(alpha: 0.4),
                      context.colorScheme.secondary.withValues(alpha: 0.4),
                    ],
                  ),
                ),
                child: IconButton(
                  onPressed: _scrollToBottom,
                  icon: Icon(
                    Icons.arrow_downward_outlined,
                    color: context.colorScheme.onPrimary,
                    size: 18,
                  ),
                ),
              ).addPadding(bottom: 80);
            },
          ),

          body: ChatBackGround(
            child: Stack(
              children: [
                Column(
                  children: [
                    ChatAppBar(chat: state.chat),
                    const SizedBox(height: 5),

                    // ✅ Reversed message list takes remaining space
                    Expanded(
                      child: CustomScrollView(
                        controller: _scrollController,
                        reverse: true,
                        slivers: [
                          const SliverPadding(
                            padding: EdgeInsets.only(top: 85),
                          ),

                          if (state.chatState.isLoading)
                            SliverFillRemaining(
                              child: Center(child: Loading.loader(context)),
                            )
                          else if (state.chatState.isError)
                            SliverFillRemaining(
                              child: Center(
                                child: AppText(
                                  state.chatState.message ??
                                      context.locale.unexpectedError,
                                  align: TextAlign.center,
                                ),
                              ),
                            )
                          else
                            ValueListenableBuilder<String?>(
                              valueListenable: _highlightedMessageId,
                              builder: (context, highlightedId, _) {
                                return SliverList(
                                  delegate: SliverChildBuilderDelegate((
                                    context,
                                    index,
                                  ) {
                                    final message =
                                        messages[messages.length - 1 - index];
                                    final isMe =
                                        message.senderId == _currentUid;
                                    final lastMyMessageIndex = messages
                                        .lastIndexWhere(
                                          (m) => m.senderId == _currentUid,
                                        );
                                    final isLastMyMessage =
                                        messages.length - 1 - index ==
                                        lastMyMessageIndex;
                                    final isHighlighted =
                                        message.id == highlightedId;
                                    final itemKey = _messageKeys.putIfAbsent(
                                      message.id,
                                      () => GlobalKey(),
                                    );

                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      child: AnimatedContainer(
                                        key: itemKey,
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isHighlighted
                                              ? context.colorScheme.primary
                                                    .withValues(alpha: 0.12)
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: SwipeToReply(
                                          isMe: isMe,
                                          onSwipe: message.isDeleted
                                              ? null
                                              : () => context
                                                    .read<ChatCubit>()
                                                    .setReplyingTo(message),
                                          child: _buildMessageBubble(
                                            message,
                                            isMe,
                                            isLastMyMessage,
                                          ),
                                        ),
                                      ),
                                    );
                                  }, childCount: messages.length),
                                );
                              },
                            ),
                        ],
                      ),
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
                    memberNames: state.chat?.memberNames ?? {},
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
    );
  }

  Widget _buildMessageBubble(
    MessageModel message,
    bool isMe,
    bool isLastMyMessage,
  ) {
    final onReplyTap = message.replyToId != null
        ? () => _scrollToMessage(message.replyToId!)
        : null;

    final memberNames = context.read<ChatCubit>().state.chat?.memberNames ?? {};

    void handleReact(String? emoji) => context.read<ChatCubit>().reactToMessage(
      messageId: message.id,
      reaction: emoji,
    );

    void handleReply() => context.read<ChatCubit>().setReplyingTo(message);

    void handleDelete() =>
        confirmDeleteMessage(context: context, messageId: message.id);

    switch (message.type) {
      case MessageType.audio:
        return VoiceMessageBubble(
          key: ValueKey(message.id),
          message: message, // ← full model
          time: _formatTime(message.createdAt),
          status: isMe && isLastMyMessage ? message.status : null,
          isMe: isMe,
          currentUid: _currentUid,
          replyToContent: message.replyToContent,
          replyToSenderId: message.replyToSenderId,
          replyToType: message.replyToType,
          onReplyTap: onReplyTap,
          memberNames: memberNames,
          onReact: handleReact,
          onReply: handleReply,
          onDelete: isMe && !message.isDeleted ? handleDelete : null,
        );

      case MessageType.image:
      case MessageType.video:
      case MessageType.file:
        return MediaMessageBubble(
          key: ValueKey(message.id),
          message: message, // ← full model
          type: message.type,
          time: _formatTime(message.createdAt),
          status: isMe && isLastMyMessage ? message.status : null,
          isMe: isMe,
          currentUid: _currentUid,
          metadata: message.metadata,
          replyToContent: message.replyToContent,
          replyToSenderId: message.replyToSenderId,
          replyToType: message.replyToType,
          onReplyTap: onReplyTap,
          memberNames: memberNames,
          onReact: handleReact,
          onReply: handleReply,
          onDelete: isMe && !message.isDeleted ? handleDelete : null,
        );

      case MessageType.text:
      default:
        return TextMessageBubble(
          key: ValueKey(message.id),
          message: message, // ← full model
          time: _formatTime(message.createdAt),
          status: isMe && isLastMyMessage ? message.status : null,
          isMe: isMe,
          isDeleted: message.isDeleted,
          messageType: message.type,
          replyToContent: message.replyToContent,
          replyToSenderId: message.replyToSenderId,
          replyToType: message.replyToType,
          currentUid: _currentUid,
          onReplyTap: onReplyTap,
          memberNames: memberNames,
          onReact: handleReact,
          onReply: handleReply,
          onDelete: handleDelete,
        );
    }
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12
        ? dt.hour - 12
        : dt.hour == 0
        ? 12
        : dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? context.locale.pm : context.locale.am;
    return '$hour:$minute $period';
  }
}

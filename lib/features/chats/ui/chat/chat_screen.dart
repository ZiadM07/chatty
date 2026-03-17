import 'package:Chatty/core/constants/exports.dart';
import 'package:Chatty/features/auth/cubits/auth_cubit.dart';
import 'package:Chatty/features/chats/cubits/chat_cubit.dart';
import 'package:Chatty/features/chats/ui/chat/widgets/chat_appbar.dart';
import 'package:Chatty/features/chats/ui/chat/widgets/chat_background.dart';
import 'package:Chatty/features/chats/ui/chat/widgets/chat_input.dart';
import 'package:Chatty/features/chats/ui/chat/widgets/confirm_delete_message.dart';
import 'package:Chatty/features/chats/ui/chat/widgets/message_bubble.dart';
import 'package:Chatty/features/chats/ui/chat/widgets/swipe_to_reply.dart';
import '../../../../core/di/injectable.dart';
import '../../../../core/utils/enums.dart';
import '../../../shared/widgets/app_toast.dart';

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
                child: Center(
                  child: Icon(
                    SolarIconsOutline.arrowDown,
                    color: context.colorScheme.onPrimary,
                    size: 18,
                  ).addAction(onBounce: _scrollToBottom),
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

                    Expanded(
                      child: CustomScrollView(
                        controller: _scrollController,
                        reverse: true,
                        slivers: [
                          SliverPadding(padding: AppPadding.set(top: 85)),

                          if (state.chatState.isLoading)
                            SliverFillRemaining(
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: context.colorScheme.secondary,
                                ),
                              ),
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

                                    return AnimatedContainer(
                                      key: itemKey,
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isHighlighted
                                            ? context.colorScheme.primary
                                                  .withValues(alpha: 0.12)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: SwipeToReply(
                                        isMe: isMe,
                                        onSwipe: message.isDeleted
                                            ? null
                                            : () => context
                                                  .read<ChatCubit>()
                                                  .setReplyingTo(message),
                                        child: MessageBubble(
                                          isGroup: state.chat?.isGroup ?? false,
                                          message: message,
                                          isMe: isMe,
                                          isLastMyMessage: isLastMyMessage,
                                          currentUid: _currentUid,
                                          memberNames:
                                              state.chat?.memberNames ?? {},
                                          onReplyTap: message.replyToId != null
                                              ? () => _scrollToMessage(
                                                  message.replyToId!,
                                                )
                                              : null,
                                          onReact: (emoji) => context
                                              .read<ChatCubit>()
                                              .reactToMessage(
                                                messageId: message.id,
                                                reaction: emoji,
                                              ),
                                          onReply: () => context
                                              .read<ChatCubit>()
                                              .setReplyingTo(message),
                                          onDelete: isMe && !message.isDeleted
                                              ? () => confirmDeleteMessage(
                                                  context: context,
                                                  messageId: message.id,
                                                )
                                              : null,
                                        ),
                                      ),
                                    ).addPadding(bottom: 6);
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
                    onSendVoice: (result) {
                      context.read<ChatCubit>().sendVoiceMessage(
                        senderId: _currentUid,
                        result: result,
                      );
                      _scrollToBottom();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

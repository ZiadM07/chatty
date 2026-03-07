import 'dart:async';

import 'package:Chatty/config/router/app_router.gr.dart';
import 'package:Chatty/core/constants/exports.dart';
import 'package:Chatty/core/di/injectable.dart';
import 'package:Chatty/features/auth/data/models/user_model.dart';
import 'package:Chatty/features/chats/data/models/chat_model.dart';
import 'package:Chatty/features/shared/widgets/app_image.dart';
import 'package:Chatty/features/shared/widgets/profile_image_dialog.dart';
import 'package:Chatty/features/stories/cubits/stories_cubit.dart';
import 'package:Chatty/features/stories/data/models/story_model.dart';
import 'package:Chatty/features/users/data/repositories/users_repository.dart';

class MessagesItem extends StatefulWidget {
  final ChatModel chat;
  final String currentUid;

  const MessagesItem({super.key, required this.chat, required this.currentUid});

  @override
  State<MessagesItem> createState() => _MessagesItemState();
}

class _MessagesItemState extends State<MessagesItem> {
  UserModel? _otherUser;
  StreamSubscription<UserModel?>? _userSubscription;

  bool get _isGroup => widget.chat.isGroup;

  @override
  void initState() {
    super.initState();
    _listenToUser();
  }

  @override
  void didUpdateWidget(covariant MessagesItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chat.id != widget.chat.id) _listenToUser();
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }

  void _listenToUser() {
    if (_isGroup) return;
    final otherUid = widget.chat.otherMemberId(widget.currentUid);
    if (otherUid.isEmpty) return;

    _userSubscription?.cancel();
    _userSubscription = getIt<UsersRepository>()
        .watchUser(uid: otherUid)
        .listen((user) {
          if (mounted) setState(() => _otherUser = user);
        });
  }

  String _lastMessagePreview(BuildContext context) {
    final message = widget.chat.lastMessage;
    if (message == null || message.isEmpty) return context.locale.noMessagesYet;
    if (!_isGroup) return message;
    return ' $message';
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return context.locale.now;
    if (diff.inHours < 1) {
      return '${diff.inMinutes} ${context.locale.minutesAgo}';
    }
    if (diff.inDays < 1) return '${diff.inHours} ${context.locale.hoursAgo}';
    if (diff.inDays < 7) return '${diff.inDays} ${context.locale.daysAgo}';
    return '${dt.day}/${dt.month}';
  }

  StoryModel? _storyFor(String otherUid, List<StoryModel> feed) {
    try {
      return feed.firstWhere((s) => s.uid == otherUid);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final unread = widget.chat.unreadCountFor(widget.currentUid);
    final otherUid = widget.chat.otherMemberId(widget.currentUid);

    final displayName = _isGroup
        ? (widget.chat.groupName ?? context.locale.groupName)
        : widget.chat.nameFor(otherUid);

    final photoUrl = _isGroup
        ? (widget.chat.groupPhotoUrl ?? AppConstants.fakeUserImage)
        : (_otherUser?.photoUrl ?? AppConstants.fakeUserImage);

    final heroTag = 'chat_avatar_${widget.chat.id}';

    return BlocBuilder<StoriesCubit, StoriesState>(
      buildWhen: (prev, curr) => prev.feedState != curr.feedState,
      builder: (context, storiesState) {
        final feed = storiesState.feedState.data ?? [];
        final story = _isGroup ? null : _storyFor(otherUid, feed);
        final hasStory = story != null;
        final isSeen = hasStory && story.isFullyViewedBy(widget.currentUid);

        return Container(
          padding: const AppPadding.set(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: hasStory
                    ? () => context.router.push(
                        StoryViewerRoute(ownerUid: otherUid),
                      )
                    : null,
                onLongPress: () => ProfileImageDialog.show(
                  context: context,
                  imageUrl: photoUrl == AppConstants.fakeUserImage
                      ? null
                      : photoUrl,
                  name: displayName,
                  heroTag: heroTag,
                ),
                child: Hero(
                  tag: heroTag,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: hasStory
                            ? BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: isSeen
                                    ? null
                                    : LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          context.colorScheme.primary,
                                          context.colorScheme.secondary,
                                        ],
                                      ),
                                color: isSeen
                                    ? context
                                          .colorScheme
                                          .surfaceContainerHighest
                                    : null,
                                border: isSeen
                                    ? Border.all(
                                        color: context
                                            .colorScheme
                                            .surfaceContainerHighest,
                                        width: 0.5,
                                      )
                                    : null,
                              )
                            : null,
                        child: AppImage(
                          imageUrl: photoUrl,
                          width: 55,
                          height: 55,
                          borderRadius: 100,
                        ),
                      ),

                      if (!_isGroup)
                        Positioned(
                          right: 2,
                          bottom: 0,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: (_otherUser?.isOnline ?? false)
                                  ? context.colorScheme.success
                                  : context.colorScheme.onSurfaceDisabled,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: context.colorScheme.surfaceContainerHigh,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  spacing: 5,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppText(
                      displayName,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                    ),
                    AppText(
                      _lastMessagePreview(context),
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.textSecondary,
                        fontWeight: unread > 0
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                      maxLines: 1,
                      maxWidth: 200,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Column(
                spacing: 6,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (widget.chat.lastMessageAt != null)
                    AppText(
                      autoSized: false,
                      _formatTime(widget.chat.lastMessageAt!),
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.textSecondary,
                        fontWeight: FontWeight.w400,
                        fontSize: 9,
                      ),
                    ),

                  if (unread > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            context.colorScheme.primary,
                            context.colorScheme.secondary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: AppText(
                        unread > 99 ? '99+' : '$unread',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  else
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 18,
                      color: context.colorScheme.textSecondary,
                    ),
                ],
              ),
            ],
          ),
        ).addAction(
          onTap: () => context.router.push(ChatRoute(chatId: widget.chat.id)),
        );
      },
    );
  }
}

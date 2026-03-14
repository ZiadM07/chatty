import 'dart:async';
import 'package:Chatty/core/constants/exports.dart';
import 'package:Chatty/core/di/injectable.dart';
import 'package:Chatty/features/auth/cubits/auth_cubit.dart';
import 'package:Chatty/features/auth/data/models/user_model.dart';
import 'package:Chatty/features/chats/data/models/chat_model.dart';
import 'package:Chatty/features/shared/cubits/app_cubit.dart';
import 'package:Chatty/features/shared/widgets/app_image.dart';
import 'package:Chatty/features/shared/widgets/app_widget_direction.dart';
import 'package:Chatty/features/shared/widgets/profile_image_dialog.dart';
import 'package:Chatty/features/users/data/repositories/users_repository.dart';
import 'package:Chatty/config/router/app_router.gr.dart';

import '../../../../shared/widgets/profile_placeholder.dart';

class ChatAppBar extends StatefulWidget {
  final ChatModel? chat;
  const ChatAppBar({super.key, required this.chat});

  @override
  State<ChatAppBar> createState() => _ChatAppBarState();
}

class _ChatAppBarState extends State<ChatAppBar> {
  UserModel? _otherUser;
  StreamSubscription<UserModel?>? _userSubscription;

  @override
  void didUpdateWidget(covariant ChatAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chat?.id != widget.chat?.id) _listenToOtherUser();
  }

  @override
  void initState() {
    super.initState();
    _listenToOtherUser();
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }

  void _listenToOtherUser() {
    final chat = widget.chat;
    if (chat == null || chat.isGroup) return;
    final currentUid = context.read<AuthCubit>().state.currentUser?.uid ?? '';
    final otherUid = chat.otherMemberId(currentUid);
    if (otherUid.isEmpty) return;

    _userSubscription?.cancel();
    _userSubscription = getIt<UsersRepository>()
        .watchUser(uid: otherUid)
        .listen((user) {
          if (mounted) setState(() => _otherUser = user);
        });
  }

  @override
  Widget build(BuildContext context) {
    final chat = widget.chat;
    final currentUid = context.read<AuthCubit>().state.currentUser?.uid ?? '';
    final isGroup = chat?.isGroup ?? false;

    final String? photoUrl;
    final String displayName;
    final String? navigateUid;

    if (isGroup) {
      photoUrl = chat!.groupPhotoUrl;
      displayName = chat.groupName!;
      navigateUid = null;
    } else {
      photoUrl = _otherUser!.photoUrl;
      final otherUid = chat?.otherMemberId(currentUid) ?? '';
      displayName = chat?.nameFor(otherUid) ?? _otherUser?.displayName ?? '...';
      navigateUid = otherUid.isEmpty ? null : otherUid;
    }

    final heroTag = 'chat_appbar_avatar_${chat?.id ?? 'unknown'}';

    return Material(
      // ← was SliverAppBar
      color: context.colorScheme.surface,
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(24),
        bottomRight: Radius.circular(24),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              AppWidgetDirection(
                child: IconButton(
                  onPressed: () => AutoRouterX(context).maybePop(),
                  icon: const Icon(SolarIconsOutline.altArrowLeft),
                ),
              ),
              const SizedBox(width: 5),
              GestureDetector(
                onLongPress: () => ProfileImageDialog.show(
                  context: context,
                  imageUrl: photoUrl,
                  name: displayName,
                  heroTag: heroTag,
                ),
                child: Hero(
                  tag: heroTag,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      photoUrl != null
                          ? AppImage(
                              imageUrl: photoUrl,
                              width: 40,
                              height: 40,
                              borderRadius: 100,
                            )
                          : ProfilePlaceholder(name: displayName, size: 40),
                      if (!isGroup)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: (_otherUser?.isOnline ?? false)
                                  ? context.colorScheme.success
                                  : context.colorScheme.onSurfaceDisabled,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              AppText(
                displayName,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.colorScheme.textPrimary,
                ),
                maxLines: 1,
              ).addAction(
                onTap: () {
                  if (navigateUid != null && chat != null) {
                    context.router.push(
                      ChatInfoRoute(uid: navigateUid, chatId: chat.id),
                    );
                  }
                  if (chat != null && chat.isGroup) {
                    context.router.push(ChatInfoRoute(chatId: chat.id));
                  }
                },
              ),
              const Spacer(),
              _MenuButton(chat: chat, navigateUid: navigateUid),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final ChatModel? chat;
  final String? navigateUid;
  const _MenuButton({required this.chat, required this.navigateUid});

  @override
  Widget build(BuildContext context) {
    final isAr = context.read<AppCubit>().isArSelected.value;

    return IconButton(
      onPressed: () {
        showMenu(
          color: context.colorScheme.surfaceContainer,
          context: context,
          position: isAr
              ? RelativeRect.fromLTRB(0, 95, 100, 0)
              : RelativeRect.fromLTRB(100, 95, 0, 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),

          items: [
            PopupMenuItem(
              child: AppText(
                context.locale.mediaAndFiles,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.textPrimary,
                ),
                autoSized: false,
              ),
              onTap: () {
                context.router.push(ChatMediaRoute(chatId: chat!.id));
              },
            ),
            PopupMenuItem(
              child: AppText(
                context.locale.chatWallpaper,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.textPrimary,
                ),
                autoSized: false,
              ),
              onTap: () {
                context.router.replace(const ChatWallpaperRoute());
              },
            ),
            PopupMenuItem(
              child: AppText(
                context.locale.chatInfo,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.textPrimary,
                ),
                autoSized: false,
              ),
              onTap: () {
                if (navigateUid != null && chat != null) {
                  context.router.push(
                    ChatInfoRoute(uid: navigateUid, chatId: chat?.id),
                  );
                }
                if (chat != null && chat!.isGroup) {
                  context.router.push(ChatInfoRoute(chatId: chat?.id));
                }
              },
            ),
          ],
        );
      },
      icon: Icon(
        Icons.more_vert_rounded,
        size: 20,
        color: context.colorScheme.textPrimary,
      ),
    );
  }
}

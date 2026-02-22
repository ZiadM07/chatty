import 'package:chatty/config/router/app_router.gr.dart';
import 'package:chatty/core/constants/exports.dart';
import 'package:chatty/core/di/injectable.dart';
import 'package:chatty/features/auth/cubits/auth_cubit.dart';
import 'package:chatty/features/auth/data/models/user_model.dart';
import 'package:chatty/features/chats/data/models/chat_model.dart';
import 'package:chatty/features/shared/widgets/app_image.dart';
import 'package:chatty/features/users/data/repositories/users_repository.dart';

class ChatAppBar extends StatefulWidget {
  final ChatModel? chat;
  const ChatAppBar({super.key, required this.chat});

  @override
  State<ChatAppBar> createState() => _ChatAppBarState();
}

class _ChatAppBarState extends State<ChatAppBar> {
  UserModel? _otherUser;

  @override
  void didUpdateWidget(covariant ChatAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-fetch if chat changed (e.g. first load was null, now it's set)
    if (oldWidget.chat?.id != widget.chat?.id) {
      _loadOtherUser();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadOtherUser();
  }

  Future<void> _loadOtherUser() async {
    final chat = widget.chat;
    if (chat == null || chat.isGroup) return;

    final currentUid = context.read<AuthCubit>().state.currentUser?.uid ?? '';
    final otherUid = chat.otherMemberId(currentUid);
    if (otherUid.isEmpty) return;

    final user = await getIt<UsersRepository>().getUserById(uid: otherUid);
    if (mounted) setState(() => _otherUser = user);
  }

  @override
  Widget build(BuildContext context) {
    final chat = widget.chat;
    final currentUid = context.read<AuthCubit>().state.currentUser?.uid ?? '';
    final isGroup = chat?.isGroup ?? false;

    // ─── Resolve display values ───────────────────────────────────────────
    final String photoUrl;
    final String displayName;
    final String? navigateUid;

    if (isGroup) {
      photoUrl = chat?.groupPhotoUrl ?? AppConstants.fakeUserImage;
      displayName = chat?.groupName ?? context.locale.groupName;
      navigateUid = null;
    } else {
      photoUrl = _otherUser?.photoUrl ?? AppConstants.fakeUserImage;
      displayName =
          _otherUser?.displayName ??
          (_otherUser == null
              ? '...'
              : chat?.otherMemberId(currentUid) ?? '...');
      navigateUid = chat?.otherMemberId(currentUid);
    }

    return SliverAppBar(
      expandedHeight: 50,
      automaticallyImplyLeading: false,
      pinned: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      flexibleSpace: Row(
        children: [
          /* ─── Back ─── */
          IconButton(
            onPressed: () => AutoRouterX(context).maybePop(),
            icon: const Icon(SolarIconsOutline.altArrowLeft),
          ),

          const SizedBox(width: 5),

          /* ─── Avatar ─── */
          AppImage(
            imageUrl: photoUrl,
            width: 40,
            height: 40,
            borderRadius: 100,
          ),

          const SizedBox(width: 12),

          /* ─── Name ─── */
          Expanded(
            child:
                AppText(
                  displayName,
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: context.colorScheme.textPrimary,
                  ),
                  maxLines: 1,
                ).addAction(
                  onTap: navigateUid != null
                      ? () => context.router.push(
                          UserInfoRoute(uid: navigateUid!, chatId: chat!.id),
                        )
                      : null,
                ),
          ),

          /* ─── More options ─── */
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.more_vert_rounded,
              size: 20,
              color: context.colorScheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:Chatty/core/constants/exports.dart';
import 'package:Chatty/core/framework/pick_file.dart';
import 'package:Chatty/features/chats/data/models/chat_model.dart';
import 'package:Chatty/features/chats/cubits/chat_info_cubit.dart';
import 'package:Chatty/features/shared/widgets/app_image.dart';
import 'package:Chatty/features/shared/widgets/profile_placeholder.dart';
import 'package:intl/intl.dart';

class GroupInfoSection extends StatefulWidget {
  final ChatModel? chat;
  final String currentUid;
  final bool isOwner;

  const GroupInfoSection({
    super.key,
    required this.chat,
    required this.currentUid,
    required this.isOwner,
  });

  @override
  State<GroupInfoSection> createState() => _GroupInfoSectionState();
}

class _GroupInfoSectionState extends State<GroupInfoSection> {
  bool get _isOwner => widget.isOwner;
  ChatModel? get _chat => widget.chat;

  void _editName() {
    if (_chat == null) return;

    final ctrl = TextEditingController(text: _chat!.groupName ?? '');
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: AppText(
          autoSized: false,
          context.locale.editGroupName,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLength: 60,
          decoration: InputDecoration(
            hintText: context.locale.groupName,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: AppText(
              autoSized: false,
              context.locale.cancel,
              style: context.textTheme.labelLarge,
            ),
          ),
          FilledButton(
            onPressed: () {
              final name = ctrl.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(dialogContext);
              context.read<ChatInfoCubit>().updateGroupInfo(
                chatId: _chat!.id,
                groupName: name,
                oldGroupPhotoUrl: _chat!.groupPhotoUrl,
              );
            },
            child: AppText(
              autoSized: false,
              context.locale.save,
              style: context.textTheme.labelLarge?.copyWith(
                color: context.colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editDescription() {
    if (_chat == null) return;

    final ctrl = TextEditingController(text: _chat!.groupDescription ?? '');
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: AppText(
          autoSized: false,

          context.locale.editGroupDescription,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLength: 200,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: context.locale.groupDescriptionHint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: AppText(
              autoSized: false,

              context.locale.cancel,
              style: context.textTheme.labelLarge,
            ),
          ),
          FilledButton(
            onPressed: () {
              final desc = ctrl.text.trim();
              Navigator.pop(dialogContext);
              context.read<ChatInfoCubit>().updateGroupInfo(
                chatId: _chat!.id,
                groupDescription: desc.isEmpty ? null : desc,
              );
            },
            child: AppText(
              autoSized: false,

              context.locale.save,
              style: context.textTheme.labelLarge?.copyWith(
                color: context.colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editPhoto() async {
    if (_chat == null) return;

    final file = await PickFile.image();
    if (file == null || !mounted) return;
    context.read<ChatInfoCubit>().updateGroupInfo(
      chatId: _chat!.id,
      groupPhotoFile: file,
      oldGroupPhotoUrl: _chat!.groupPhotoUrl,
    );
  }

  void _showGroupPhoto(BuildContext context) {
    if (_chat?.groupPhotoUrl == null) return;
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withValues(alpha: 0.92),
      transitionDuration: const Duration(milliseconds: 220),
      transitionBuilder: (context, animation, _, child) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween(
            begin: 0.92,
            end: 1.0,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: child,
        ),
      ),
      pageBuilder: (context, _, i) =>
          _GroupImageViewer(photoUrl: _chat!.groupPhotoUrl!),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_chat == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _showGroupPhoto(context),
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        context.colorScheme.primary.withValues(alpha: 0.1),
                        context.colorScheme.secondary.withValues(alpha: 0.1),
                      ],
                    ),
                  ),
                  child: _chat!.groupPhotoUrl != null
                      ? AppImage(
                          imageUrl: _chat!.groupPhotoUrl!,
                          width: 100,
                          height: 100,
                          borderRadius: 50,
                        )
                      : ProfilePlaceholder(name: _chat!.groupName!, size: 100),
                ),
                if (_isOwner)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          context.colorScheme.primary,
                          context.colorScheme.secondary,
                        ],
                      ),
                      border: Border.all(
                        color: context.colorScheme.surface,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: context.colorScheme.primary.withValues(
                            alpha: 0.3,
                          ),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      SolarIconsOutline.cameraAdd,
                      size: 16,
                      color: context.colorScheme.onPrimary,
                    ).addAction(onTap: _isOwner ? _editPhoto : null),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          GestureDetector(
            onTap: _isOwner ? _editName : null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: AppText(
                    _chat!.groupName ?? context.locale.groupName,
                    style: context.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    align: TextAlign.center,
                    maxLines: 2,
                  ),
                ),
                if (_isOwner) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: context.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      SolarIconsOutline.pen,
                      size: 16,
                      color: context.colorScheme.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  SolarIconsOutline.usersGroupRounded,
                  size: 16,
                  color: context.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                AppText(
                  context.locale.membersCount(_chat!.memberIds.length),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          if (_chat!.groupDescription != null &&
              _chat!.groupDescription!.isNotEmpty) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _isOwner ? _editDescription : null,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                context.colorScheme.primary.withValues(
                                  alpha: 0.1,
                                ),
                                context.colorScheme.secondary.withValues(
                                  alpha: 0.1,
                                ),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            SolarIconsOutline.documentText,
                            size: 18,
                            color: context.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AppText(
                            context.locale.description,
                            style: context.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: context.colorScheme.primary,
                            ),
                          ),
                        ),
                        if (_isOwner)
                          Icon(
                            SolarIconsOutline.pen,
                            size: 14,
                            color: context.colorScheme.primary.withValues(
                              alpha: 0.6,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    AppText(
                      _chat!.groupDescription!,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurface,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else if (_isOwner) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _editDescription,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: context.colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: context.colorScheme.outline.withValues(alpha: 0.2),
                    width: 1,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      SolarIconsOutline.addCircle,
                      size: 20,
                      color: context.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppText(
                        context.locale.addGroupDescription,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: context.colorScheme.primary.withValues(alpha: 0.5),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                SolarIconsOutline.calendarMinimalistic,
                size: 16,
                color: context.colorScheme.textSecondary,
              ),
              const SizedBox(width: 8),
              AppText(
                '${context.locale.createdAt} ${DateFormat('MMMM yyyy').format(_chat!.createdAt)}',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GroupImageViewer extends StatelessWidget {
  final String photoUrl;
  const _GroupImageViewer({required this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Center(
            child: AppImage(
              imageUrl: photoUrl,
              width: context.width,
              height: context.width,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 12,
            left: 5,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: AppBorderRadius.set(all: 12),
              ),
              child: Icon(
                SolarIconsOutline.altArrowLeft,
                color: Colors.white,
                size: 25,
              ),
            ).addAction(onBounce: () => context.router.maybePop()),
          ),
        ],
      ),
    );
  }
}

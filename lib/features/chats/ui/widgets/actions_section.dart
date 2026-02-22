import 'package:chatty/core/constants/exports.dart';

class ActionsSection extends StatelessWidget {
  final bool isLoadingChat;
  final VoidCallback onMessage;

  const ActionsSection({
    super.key,
    required this.isLoadingChat,
    required this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        /* ─── Message ─── */
        _ActionButton(
          icon: isLoadingChat
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: context.colorScheme.onPrimary,
                  ),
                )
              : Icon(
                  SolarIconsOutline.chatRoundLine,
                  color: context.colorScheme.onPrimary,
                ),
          label: context.locale.message,
          onTap: isLoadingChat ? null : onMessage,
        ),

        /* ─── View Story ─── */
        _ActionButton(
          icon: Icon(
            SolarIconsOutline.userHeartRounded,
            color: context.colorScheme.onPrimary,
          ),
          label: context.locale.viewStory,
          onTap: () {
            // TODO: wire story navigation
          },
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: onTap == null
                ? null
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      context.colorScheme.primary,
                      context.colorScheme.secondary,
                    ],
                  ),
            color: onTap == null
                ? context.colorScheme.surfaceContainerHigh
                : null,
            shape: BoxShape.circle,
          ),
          child: IconButton(onPressed: onTap, icon: icon),
        ),
        const SizedBox(height: 5),
        AppText(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colorScheme.textPrimary,
          ),
        ),
      ],
    );
  }
}

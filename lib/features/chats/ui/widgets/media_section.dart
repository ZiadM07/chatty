import 'package:Chatty/config/router/app_router.gr.dart';
import 'package:Chatty/core/constants/exports.dart';
import 'package:Chatty/core/di/injectable.dart';
import 'package:Chatty/features/chats/cubits/chat_media_cubit.dart';

class MediaSection extends StatelessWidget {
  final String? chatId;
  const MediaSection({super.key, this.chatId});

  @override
  Widget build(BuildContext context) {
    if (chatId == null) {
      return const SizedBox.shrink();
    }

    return BlocProvider(
      create: (_) => getIt<ChatMediaCubit>()..loadCount(chatId: chatId!),
      child: _MediaSectionContent(chatId: chatId!),
    );
  }
}

class _MediaSectionContent extends StatelessWidget {
  final String chatId;
  const _MediaSectionContent({required this.chatId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatMediaCubit, ChatMediaState>(
      builder: (context, state) {
        final count = state.count;

        return Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        context.colorScheme.primary,
                        context.colorScheme.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    SolarIconsOutline.fileText,
                    color: context.colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        context.locale.mediaLinks,
                        size: 15,
                        weight: FontWeight.w600,
                      ),
                      AppText(
                        state.mediaState.isLoading
                            ? context.locale.loading
                            : count == 0
                            ? context.locale.noSharedFiles
                            : context.locale.sharedFiles,
                        size: 12,
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
                if (count > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
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
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: AppText(
                      count > 99 ? '99+' : count.toString(),
                      size: 14,
                      color: context.colorScheme.onPrimary,
                      weight: FontWeight.w700,
                    ),
                  ),
                if (count > 0) const SizedBox(width: 8),
                Icon(Icons.chevron_right, color: context.colorScheme.onSurface),
              ],
            )
            .addPadding(horizontal: 20, vertical: 5)
            .addAction(
              onTap: count > 0
                  ? () => context.router.push(ChatMediaRoute(chatId: chatId))
                  : null,
            );
      },
    );
  }
}

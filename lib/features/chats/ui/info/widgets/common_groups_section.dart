import 'package:Chatty/config/router/app_router.gr.dart';
import 'package:Chatty/core/constants/exports.dart';
import 'package:Chatty/features/shared/widgets/app_image.dart';

class CommonGroupsSection extends StatelessWidget {
  final List<dynamic> groups;
  final String currentUid;

  const CommonGroupsSection({
    super.key,
    required this.groups,
    required this.currentUid,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        context.colorScheme.primary,
                        context.colorScheme.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    SolarIconsOutline.usersGroupRounded,
                    size: 18,
                    color: context.colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                AppText(
                  '${groups.length} ${context.locale.commonGroups}',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, indent: 16, endIndent: 16),

          ...groups.map(
            (group) => ListTile(
              leading: AppImage(
                imageUrl: group.groupPhotoUrl!,
                borderRadius: 100,
                width: 50,
                height: 50,
              ),
              title: Text(group.groupName!),
              subtitle: Text(
                '${group.memberIds.length} ${context.locale.members}',
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                context.router.push(ChatRoute(chatId: group.id));
              },
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

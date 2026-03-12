import '../../../../../core/constants/exports.dart';

class ChatMediaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController tabController;
  final TextEditingController searchController;
  final bool isSearching;
  final VoidCallback onToggleSearch;

  const ChatMediaAppBar({
    super.key,
    required this.tabController,
    required this.searchController,
    required this.isSearching,
    required this.onToggleSearch,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: isSearching
            ? TextField(
                key: const ValueKey('search'),
                controller: searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: context.locale.searchMedia,
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              )
            : Text(context.locale.media, key: const ValueKey('title')),
      ),
      actions: [
        IconButton(
          icon: Icon(isSearching ? Icons.close : SolarIconsOutline.magnifier),
          onPressed: onToggleSearch,
        ),
      ],
      bottom: TabBar(
        controller: tabController,
        indicatorWeight: 3,
        tabs: [
          Tab(text: context.locale.mediaAll),
          Tab(text: context.locale.mediaPhotos),
          Tab(text: context.locale.mediaVideos),
          Tab(text: context.locale.mediaAudio),
          Tab(text: context.locale.mediaDocs),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(104);
}

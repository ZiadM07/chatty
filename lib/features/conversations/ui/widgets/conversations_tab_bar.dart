import 'package:chatty/core/constants/exports.dart';

class ConversationsTabBar extends StatelessWidget {
  const ConversationsTabBar({super.key, required TabController tabController})
    : _tabController = tabController;

  final TabController _tabController;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      delegate: _SliverTabBarDelegate(
        TabBar(
          controller: _tabController,

          tabs: [
            Tab(text: context.locale.messages),
            Tab(text: context.locale.groups),
          ],
          indicatorColor: context.colorScheme.primary,
          labelColor: context.colorScheme.primary,
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.label,
          indicatorWeight: 2,
          labelStyle: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}


class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    // This container provides the background color that matches the scaffold,
    // ensuring a seamless look when the TabBar sticks to the top.
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    // Only rebuild if the TabBar instance itself has changed.
    return tabBar != oldDelegate.tabBar;
  }
}

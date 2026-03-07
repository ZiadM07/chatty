import 'package:Chatty/core/constants/exports.dart';
import 'package:Chatty/features/chats/cubits/conversations_cubit.dart';

class ConversationsAppBar extends StatefulWidget {
  const ConversationsAppBar({super.key});

  @override
  State<ConversationsAppBar> createState() => _ConversationsAppBarState();
}

class _ConversationsAppBarState extends State<ConversationsAppBar>
    with SingleTickerProviderStateMixin {
  bool _showSearch = false;
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  late final AnimationController _controller;
  late final Animation<double> _expand;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expand = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _openSearch() {
    setState(() => _showSearch = true);
    _controller.forward();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _searchFocus.requestFocus(),
    );
  }

  void _closeSearch() {
    _searchFocus.unfocus();
    _controller.reverse().then((_) {
      if (mounted) setState(() => _showSearch = false);
    });
    _searchController.clear();
    context.read<ConversationsCubit>().clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      titleSpacing: 0,
      centerTitle: false,
      title: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 12, 0),
        child: AnimatedBuilder(
          animation: _expand,
          builder: (context, _) {
            return Row(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Opacity(
                        opacity: (1 - _expand.value).clamp(0.0, 1.0),
                        child: IgnorePointer(
                          ignoring: _expand.value > 0.1,
                          child: AppText(
                            context.locale.conversations,
                            style: context.textTheme.headlineSmall,
                          ),
                        ),
                      ),

                      Opacity(
                        opacity: _expand.value.clamp(0.0, 1.0),
                        child: Transform.translate(
                          offset: Offset(10 * (1 - _expand.value), 0),
                          child: IgnorePointer(
                            ignoring: _expand.value < 0.9,
                            child: _ConversationsSearchBar(
                              controller: _searchController,
                              focusNode: _searchFocus,
                              onChanged: (v) =>
                                  context.read<ConversationsCubit>().search(v),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                _SearchToggleButton(
                  isClose: _showSearch,
                  onTap: _showSearch ? _closeSearch : _openSearch,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ConversationsSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _ConversationsSearchBar({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Icon(
            SolarIconsOutline.magnifier,
            size: 18,
            color: context.colorScheme.textSecondary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              style: context.textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: context.locale.searchConversations,
                hintStyle: context.textTheme.bodyLarge?.copyWith(
                  color: context.colorScheme.textSecondary,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchToggleButton extends StatelessWidget {
  final bool isClose;
  final VoidCallback onTap;

  const _SearchToggleButton({required this.isClose, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 100),
        transitionBuilder: (child, anim) => ScaleTransition(
          scale: anim,
          child: FadeTransition(opacity: anim, child: child),
        ),
        child: Container(
          key: ValueKey(isClose),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isClose
                ? context.colorScheme.primary.withValues(alpha: 0.12)
                : context.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isClose ? Icons.close_rounded : SolarIconsOutline.magnifier,
            size: 20,
            color: isClose
                ? context.colorScheme.primary
                : context.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

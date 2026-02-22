import '../../../../core/constants/exports.dart';

class ChatMediaEmptyState extends StatefulWidget {
  final String search;

  const ChatMediaEmptyState({super.key, required this.search});

  @override
  State<ChatMediaEmptyState> createState() => _ChatMediaEmptyStateState();
}

class _ChatMediaEmptyStateState extends State<ChatMediaEmptyState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    )..forward();

    _scale = Tween(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    final isSearch = widget.search.isNotEmpty;

    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: isSearch
                          ? [cs.surfaceContainerHighest, cs.surfaceContainer]
                          : [cs.primaryContainer, cs.secondaryContainer],
                    ),
                  ),
                  child: Icon(
                    isSearch
                        ? Icons.search_off_rounded
                        : Icons.perm_media_rounded,
                    size: 72,
                    color: isSearch
                        ? cs.onSurface.withValues(alpha: 0.6)
                        : cs.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  isSearch
                      ? context.locale.noResultsFound
                      : context.locale.noMediaYet,
                  textAlign: TextAlign.center,
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isSearch
                      ? context.locale.adjustSearchKeywords
                      : context.locale.mediaEmptyDescription,
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

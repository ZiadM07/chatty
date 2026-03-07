import 'package:Chatty/core/constants/exports.dart';
import 'package:Chatty/core/di/injectable.dart';
import 'package:Chatty/features/shared/widgets/app_image.dart';
import 'package:Chatty/features/users/data/repositories/users_repository.dart';

class StoryViewersSheet extends StatelessWidget {
  final List<String> viewerIds;
  final List<String> likeIds;

  const StoryViewersSheet({
    super.key,
    required this.viewerIds,
    required this.likeIds,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          _SheetHandle(),
          const SizedBox(height: 20),
          _SheetTitle(viewCount: viewerIds.length, likeCount: likeIds.length),
          const SizedBox(height: 8),
          if (viewerIds.isEmpty)
            _EmptyViewers()
          else
            _ViewerList(viewerIds: viewerIds, likeIds: likeIds),
        ],
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: context.colorScheme.outline.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _SheetTitle extends StatelessWidget {
  final int viewCount;
  final int likeCount;

  const _SheetTitle({required this.viewCount, required this.likeCount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          AppText(
            '$viewCount ${context.locale.viewers}',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          if (likeCount > 0) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: context.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    SolarIconsBold.heart,
                    size: 13,
                    color: context.colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  AppText(
                    '$likeCount',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyViewers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.visibility_off_rounded,
            size: 40,
            color: context.colorScheme.outline.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          AppText(
            context.locale.noViewsYet,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewerList extends StatelessWidget {
  final List<String> viewerIds;
  final List<String> likeIds;

  const _ViewerList({required this.viewerIds, required this.likeIds});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.45,
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: viewerIds.length,
        separatorBuilder: (_, i) => Divider(
          height: 1,
          color: context.colorScheme.outline.withValues(alpha: 0.08),
        ),
        itemBuilder: (_, i) => StoryViewerTile(
          uid: viewerIds[i],
          hasLiked: likeIds.contains(viewerIds[i]),
        ),
      ),
    );
  }
}

class StoryViewerTile extends StatefulWidget {
  final String uid;
  final bool hasLiked;

  const StoryViewerTile({super.key, required this.uid, required this.hasLiked});

  @override
  State<StoryViewerTile> createState() => _StoryViewerTileState();
}

class _StoryViewerTileState extends State<StoryViewerTile> {
  String? _name;
  String? _photo;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await getIt<UsersRepository>().getUserById(uid: widget.uid);
    if (mounted) {
      setState(() {
        _name = user?.displayName;
        _photo = user?.photoUrl;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          AppImage(
            imageUrl: _photo ?? AppConstants.fakeUserImage,
            width: 44,
            height: 44,
            borderRadius: 100,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AppText(
              _name ?? '...',
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (widget.hasLiked)
            Icon(
              SolarIconsBold.heart,
              size: 18,
              color: context.colorScheme.primary,
            ),
        ],
      ),
    );
  }
}

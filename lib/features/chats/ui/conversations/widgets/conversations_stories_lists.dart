import 'package:Chatty/config/router/app_router.gr.dart';
import 'package:Chatty/core/constants/exports.dart';
import 'package:Chatty/features/auth/cubits/auth_cubit.dart';
import 'package:Chatty/features/chats/cubits/conversations_cubit.dart';
import 'package:Chatty/features/profile/cubits/profile_cubit.dart';
import 'package:Chatty/features/stories/cubits/stories_cubit.dart';
import 'package:Chatty/features/shared/widgets/app_image.dart';
import 'package:Chatty/features/stories/data/models/story_item_model.dart';
import 'package:Chatty/features/stories/data/models/story_model.dart';
import '../../../../shared/widgets/profile_placeholder.dart';

class ConversationsStoriesLists extends StatefulWidget {
  const ConversationsStoriesLists({super.key});

  @override
  State<ConversationsStoriesLists> createState() =>
      _ConversationsStoriesListsState();
}

class _ConversationsStoriesListsState extends State<ConversationsStoriesLists> {
  bool _feedSeeded = false;

  void _trySeedFeed(BuildContext context) {
    if (_feedSeeded) return;
    final chatsState = context.read<ConversationsCubit>().state.chatsState;
    if (chatsState.status != StateStatus.success) return;

    final uid = context.read<AuthCubit>().state.currentUser?.uid ?? '';
    final chats = chatsState.data ?? [];

    final contactUids = chats
        .where((c) => c.isOneToOne)
        .map((c) => c.otherMemberId(uid))
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();

    context.read<StoriesCubit>().watchFeedStories(
      uid: uid,
      contactUids: contactUids,
    );

    _feedSeeded = true;
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: BlocListener<ConversationsCubit, ConversationsState>(
        listenWhen: (prev, curr) =>
            prev.chatsState.status != curr.chatsState.status &&
            curr.chatsState.status == StateStatus.success,
        listener: (context, _) => _trySeedFeed(context),
        child: BlocBuilder<StoriesCubit, StoriesState>(
          buildWhen: (prev, curr) =>
              prev.myStoryState != curr.myStoryState ||
              prev.feedState != curr.feedState,
          builder: (context, state) {
            _trySeedFeed(context);

            final uid = context.read<AuthCubit>().state.currentUser?.uid ?? '';
            final myItems = state.myStoryState.data ?? [];
            final feedStories = state.feedState.data ?? [];

            if (myItems.isEmpty && feedStories.isEmpty) {
              return _MyStoryItem(
                uid: uid,
                myItems: myItems,
              ).addPadding(horizontal: 16, top: 16, bottom: 16);
            }

            return SizedBox(
              height: 110,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                scrollDirection: Axis.horizontal,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemCount: 1 + feedStories.length,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _MyStoryItem(uid: uid, myItems: myItems);
                  }
                  final story = feedStories[index - 1];
                  return _ContactStoryItem(story: story, currentUid: uid);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MyStoryItem extends StatelessWidget {
  final String uid;
  final List<StoryItemModel> myItems;

  const _MyStoryItem({required this.uid, required this.myItems});

  @override
  Widget build(BuildContext context) {
    final hasStory = myItems.isNotEmpty;

    return _StoryRing(
      photoUrl: context.read<ProfileCubit>().state.profile?.photoUrl,
      label: context.locale.you,
      hasStory: hasStory,
      isSeen: false,
      showAddButton: true,
      onAddTap: () => context.router.push(const AddStoryRoute()),
      onTap: hasStory
          ? () => context.router.push(StoryViewerRoute(ownerUid: uid))
          : () => context.router.push(const AddStoryRoute()),
    );
  }
}

class _ContactStoryItem extends StatelessWidget {
  final StoryModel story;
  final String currentUid;

  const _ContactStoryItem({required this.story, required this.currentUid});

  @override
  Widget build(BuildContext context) {
    final isSeen = story.isFullyViewedBy(currentUid);

    return _StoryRing(
      photoUrl: story.photoUrl,
      label: story.displayName,
      hasStory: true,
      isSeen: isSeen,
      showAddButton: false,
      onTap: () => context.router.push(StoryViewerRoute(ownerUid: story.uid)),
    );
  }
}

class _StoryRing extends StatelessWidget {
  final String? photoUrl;
  final String label;
  final bool hasStory;
  final bool isSeen;
  final bool showAddButton;
  final VoidCallback? onTap;
  final VoidCallback? onAddTap;

  const _StoryRing({
    required this.photoUrl,
    required this.label,
    required this.hasStory,
    required this.isSeen,
    required this.showAddButton,
    this.onTap,
    this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: !hasStory || isSeen
                    ? BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.colorScheme.surfaceContainerHighest,
                        border: Border.all(
                          color: context.colorScheme.surfaceContainerHighest,
                          width: 0.5,
                        ),
                      )
                    : BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            context.colorScheme.primary,
                            context.colorScheme.secondary,
                          ],
                        ),
                      ),
                child: photoUrl != null
                    ? AppImage(
                        fit: BoxFit.cover,
                        imageUrl: photoUrl!,
                        width: 60,
                        height: 60,
                        borderRadius: 100,
                      )
                    : ProfilePlaceholder(name: label, size: 60),
              ),

              if (showAddButton)
                Positioned(
                  bottom: -3,
                  right: 0,
                  child: GestureDetector(
                    onTap: onAddTap,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.colorScheme.primary,
                        border: Border.all(
                          color: context.colorScheme.surface,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        SolarIconsOutline.cameraAdd,
                        size: 14,
                        color: context.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(
            width: 66,
            child: AppText(
              label,
              align: TextAlign.center,
              maxLines: 1,
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colorScheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

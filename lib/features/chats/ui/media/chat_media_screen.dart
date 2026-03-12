import 'package:Chatty/core/constants/exports.dart';
import 'package:Chatty/core/di/injectable.dart';
import 'package:Chatty/core/utils/enums.dart';
import 'package:Chatty/features/chats/cubits/chat_media_cubit.dart';
import 'package:Chatty/features/chats/ui/media/widgets/chat_media_app_bar.dart';
import 'package:Chatty/features/chats/ui/media/widgets/chat_media_empty_state.dart';
import 'package:Chatty/features/chats/ui/media/widgets/chat_media_grid.dart';
import 'package:Chatty/features/shared/widgets/app_loading.dart';
import 'package:Chatty/features/shared/widgets/app_toast.dart';

@RoutePage()
class ChatMediaScreen extends StatefulWidget implements AutoRouteWrapper {
  final String chatId;

  const ChatMediaScreen({super.key, required this.chatId});

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ChatMediaCubit>()..loadMedia(chatId: chatId),
      child: this,
    );
  }

  @override
  State<ChatMediaScreen> createState() => _ChatMediaScreenState();
}

class _ChatMediaScreenState extends State<ChatMediaScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  final searchController = TextEditingController();
  final scrollController = ScrollController();

  String search = "";
  bool isSearching = false;

  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 5, vsync: this)
      ..addListener(_onTabChanged);

    searchController.addListener(() {
      setState(() => search = searchController.text);
    });

    scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    tabController.dispose();
    searchController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!tabController.indexIsChanging) return;

    final type = switch (tabController.index) {
      1 => MessageType.image,
      2 => MessageType.video,
      3 => MessageType.audio,
      4 => MessageType.file,
      _ => null,
    };

    context.read<ChatMediaCubit>().changeType(
      chatId: widget.chatId,
      type: type,
    );
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      context.read<ChatMediaCubit>().loadMore(chatId: widget.chatId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ChatMediaAppBar(
        tabController: tabController,
        searchController: searchController,
        isSearching: isSearching,
        onToggleSearch: () {
          setState(() {
            isSearching = !isSearching;
            if (!isSearching) searchController.clear();
          });
        },
      ),
      body: BlocBuilder<ChatMediaCubit, ChatMediaState>(
        builder: (context, state) {
          if (state.mediaState.isLoading && state.mediaState.data == null) {
            return Loading.loader(context);
          }

          if (state.mediaState.isError) {
            AppToast.showError(
              message: context.locale.thisOperationFailed,
              context: context,
            );
          }

          final media = state.media;

          if (media.isEmpty) {
            return ChatMediaEmptyState(search: search);
          }

          return ChatMediaGrid(
            media: media,
            tabIndex: tabController.index,
            controller: scrollController,
            hasMore: state.hasMore,
          );
        },
      ),
    );
  }
}

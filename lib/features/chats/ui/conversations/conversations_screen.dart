import 'package:Chatty/core/constants/exports.dart';
import 'package:Chatty/features/chats/ui/conversations/widgets/conversations_app_bar.dart';
import 'package:Chatty/features/chats/ui/conversations/widgets/conversations_stories_lists.dart';
import 'package:Chatty/features/chats/ui/conversations/widgets/conversations_tab_bar.dart';
import 'package:Chatty/features/chats/ui/conversations/widgets/conversations_tab_lists.dart';

@RoutePage()
class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showBackButton: false,
      appbarSize: 0,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            const ConversationsAppBar(),
            const ConversationsStoriesLists(),
            ConversationsTabBar(tabController: _tabController),
          ];
        },
        body: ConversationsTabLists(tabController: _tabController),
      ),
    );
  }
}

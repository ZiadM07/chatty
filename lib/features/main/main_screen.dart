import 'package:chatty/config/router/app_router.gr.dart';
import 'package:chatty/features/main/widgets/bottom_nav_widget.dart';

import '../../core/constants/exports.dart';

@RoutePage()
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  static const _tabs = [ConversationsRoute(), UsersRoute(), ProfileRoute()];

  @override
  Widget build(BuildContext context) {
    return AutoTabsScaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      routes: _tabs,
      bottomNavigationBuilder: (context, tabsRouter) {
        return BottomNavWidget(
          onChanged: (index) {
            tabsRouter.setActiveIndex(index);
          },
          items: [
            NavModel(name: context.locale.chats, icon: Svgs.chat,),
            NavModel(name: context.locale.contacts, icon: Svgs.message),
            NavModel(name: context.locale.profile, icon: Svgs.profile),
          ],
          index: tabsRouter.activeIndex,
        );
      },
    );
  }
}

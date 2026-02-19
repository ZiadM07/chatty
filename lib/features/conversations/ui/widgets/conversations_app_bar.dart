import 'package:chatty/core/constants/exports.dart';

class ConversationsAppBar extends StatelessWidget {
  const ConversationsAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      title: AppText(
        context.locale.conversations,
        style: context.textTheme.headlineSmall,
      ).addPadding(left: 5, top: 10),
      centerTitle: false,
      actions: [
        IconButton(
          onPressed: () {},
          icon: Icon(SolarIconsOutline.magnifier),
        ).addPadding(right: 5, top: 10),
      ],
    );
  }
}


import 'package:chatty/core/constants/exports.dart';

@RoutePage()
class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appbarSize: 0,
      showBackButton: false,
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          children: [
            AppText(context.locale.notificationSettings),
          ],
        ).addPadding(horizontal: 20),
      ),
    );
  }
}
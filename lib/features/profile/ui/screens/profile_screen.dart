import 'package:chatty/core/constants/exports.dart';
import 'package:chatty/features/profile/ui/widgets/profile_app_bar.dart';
import 'package:chatty/features/profile/ui/widgets/profile_body_list.dart';

@RoutePage()
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [const ProfileAppBar(), const ProfileBodyList()],
      ),
    );
  }
}

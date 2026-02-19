import 'package:chatty/config/router/app_router.gr.dart';
import 'package:chatty/features/shared/widgets/app_asset_image.dart';
import 'package:chatty/features/shared/widgets/app_gradient_button.dart';

import '../../../../core/constants/exports.dart';

@RoutePage()
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appbarSize: 0,
      showBackButton: false,
      body: Column(
        children: [
          const SizedBox(height: 50),

          Align(
            alignment: Alignment.center,
            child: AppAssetImage(
              Pngs.chatty,
              fit: BoxFit.contain,
              width: 200,
              height: 100,
            ),
          ),

          const SizedBox(height: 80),

          Align(
            alignment: Alignment.center,
            child: AppAssetImage(
              Pngs.socialConnection,
              fit: BoxFit.contain,
              width: 250,
              height: 250,
            ),
          ),

          const SizedBox(height: 50),
          AppText(
            context.locale.welcomeHeadline,
            style: context.textTheme.headlineSmall,
          ),
          const SizedBox(height: 100),

          AppButton(
            text: context.locale.getStarted,
            onTap: () => context.router.push(const LoginRoute()),
          ),
        ],
      ).addPadding(horizontal: 20),
    );
  }
}

import 'package:chatty/core/constants/exports.dart';
import 'package:chatty/core/di/injectable.dart';
import 'package:chatty/features/auth/cubits/auth_cubit.dart';
import 'package:chatty/features/shared/widgets/app_toast.dart';
import 'package:chatty/features/users/cubits/user_info_cubit.dart';
import 'package:chatty/features/users/cubits/user_info_state.dart';

import 'package:chatty/features/users/ui/widgets/account_info_section.dart';
import 'package:chatty/features/users/ui/widgets/actions_section.dart';
import 'package:chatty/features/users/ui/widgets/groups_section.dart';
import 'package:chatty/features/users/ui/widgets/media_section.dart';
import 'package:chatty/features/users/ui/widgets/notifications_section.dart';

import 'package:chatty/config/router/app_router.gr.dart';

@RoutePage()
class UserInfoScreen extends StatefulWidget implements AutoRouteWrapper {
  final String uid;
  const UserInfoScreen({super.key, required this.uid});

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider(create: (_) => getIt<UserInfoCubit>(), child: this);
  }

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  @override
  void initState() {
    super.initState();
    context.read<UserInfoCubit>().watchUser(uid: widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserInfoCubit, UserInfoState>(
      listenWhen: (prev, curr) => prev.openChatState != curr.openChatState,
      listener: (context, state) {
        if (state.openChatState.status == StateStatus.success) {
          context.read<UserInfoCubit>().resetOpenChatState();
          context.router.replace(ChatRoute(chatId: state.openChatState.data!));
        }
        if (state.openChatState.status == StateStatus.error) {
          context.read<UserInfoCubit>().resetOpenChatState();
          AppToast.showError(
            message:
                state.openChatState.message ?? context.locale.unexpectedError,
            context: context,
          );
        }
      },
      buildWhen: (prev, curr) =>
          prev.userState != curr.userState ||
          prev.openChatState != curr.openChatState,
      builder: (context, state) {
        return StateHandler(
          state: state.userState,
          builder: (context, user) => Scaffold(
            body: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 200,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          context.colorScheme.surfaceContainerHighest,
                          context.colorScheme.surface,
                        ],
                      ),
                    ),
                  ),
                ),
                CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      expandedHeight: 60,
                      leading: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: context.colorScheme.surfaceContainerHigh,
                        ),
                        child: IconButton(
                          onPressed: () => AutoRouterX(context).maybePop(),
                          icon: const Icon(SolarIconsOutline.altArrowLeft),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          AccountInfoSection(user: user.data),
                          const SizedBox(height: 30),
                          ActionsSection(
                            isLoadingChat:
                                state.openChatState.status ==
                                StateStatus.loading,
                            onMessage: () =>
                                context.read<UserInfoCubit>().openOrCreateChat(
                                  currentUid:
                                      context
                                          .read<AuthCubit>()
                                          .state
                                          .currentUser
                                          ?.uid ??
                                      '',
                                  otherUid: widget.uid,
                                ),
                          ),
                          const SizedBox(height: 30),
                          const NotificationsSection(),
                          const SizedBox(height: 10),
                          const MediaSection(),
                          const SizedBox(height: 20),
                          const GroupsSection(),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

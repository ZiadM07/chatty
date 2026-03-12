import 'package:Chatty/core/constants/exports.dart';
import 'package:Chatty/features/auth/cubits/auth_cubit.dart';
import 'package:Chatty/features/users/cubits/users_cubit.dart';
import 'package:Chatty/features/users/cubits/users_state.dart';
import 'package:Chatty/features/users/ui/widgets/user_item.dart';
import 'package:Chatty/features/users/ui/widgets/users_actions_row.dart';
import 'package:Chatty/features/users/ui/widgets/users_app_bar.dart';

@RoutePage()
class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final _scrollController = ScrollController();
  late final String _currentUid;

  @override
  void initState() {
    super.initState();
    _currentUid = context.read<AuthCubit>().state.currentUser?.uid ?? '';
    context.read<UsersCubit>().loadUsers(currentUid: _currentUid);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final atBottom =
        _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200;
    if (atBottom) {
      context.read<UsersCubit>().loadMore(currentUid: _currentUid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UsersCubit, UsersState>(
      builder: (context, state) {
        return AppScaffold(
          appbarSize: 0,
          showBackButton: false,
          body: CustomScrollView(
            controller: _scrollController,
            slivers: [
              const UsersAppBar(),
              const UsersActionsRow(),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Divider(
                      color: context.colorScheme.outline,
                      height: 1,
                      thickness: 1,
                    ),
                    const SizedBox(height: 20),
                    AppText(
                      context.locale.myUsers,
                      style: context.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                  ],
                ).addPadding(horizontal: 30),
              ),

              if (state.usersState.status == StateStatus.loading &&
                  state.users.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state.usersState.status == StateStatus.error &&
                  state.users.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppText(
                          state.usersState.message ??
                              context.locale.unexpectedError,
                          style: context.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => context.read<UsersCubit>().loadUsers(
                            currentUid: _currentUid,
                          ),
                          child: Text(context.locale.retry),
                        ),
                      ],
                    ),
                  ),
                )
              else if (state.users.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: AppText(
                      context.locale.noUsersFound,
                      style: context.textTheme.bodyMedium,
                    ),
                  ),
                )
              else ...[
                SliverList.separated(
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 20),
                  itemCount: state.users.length,
                  itemBuilder: (context, index) =>
                      UserItem(user: state.users[index]),
                ),

                if (state.hasMore &&
                    state.usersState.status == StateStatus.loading)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
              ],

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        );
      },
    );
  }
}

import 'package:auto_route/auto_route.dart';
import 'package:chatty/features/shared/widgets/app_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/router/app_router.gr.dart';
import '../../cubits/auth_cubit.dart';
import '../../cubits/auth_state.dart';

@RoutePage()
class StartupRedirectScreen extends StatefulWidget {
  const StartupRedirectScreen({super.key});

  @override
  State<StartupRedirectScreen> createState() => _StartupRedirectScreenState();
}

class _StartupRedirectScreenState extends State<StartupRedirectScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolveAuth());
  }

  Future<void> _resolveAuth() async {
    if (!mounted) return;

    final cubit = context.read<AuthCubit>();

    // If Firebase has already emitted (cubit state is no longer initial),
    // we can redirect immediately without waiting.
    //
    // If the state is still initial it means Firebase Auth hasn't finished
    // restoring the persisted session yet — wait for the next emission.
    final AuthState state;

    if (cubit.state.authReady) {
      state = cubit.state;
    } else {
      // Wait for the first state change — Firebase session restore fires here
      state = await cubit.stream.first;
    }

    _redirect(state);
  }

  void _redirect(AuthState state) {
    if (!mounted) return;

    final user = state.currentUser;

    if (user == null) {
      context.router.replaceAll([const UnauthenticatedRoutes()]);
      return;
    }

    if (user.needsProfileSetup) {
      context.router.replaceAll([
        UnauthenticatedRoutes(children: [const FillProfileRoute()]),
      ]);
      return;
    }

    context.router.replaceAll([const AuthenticatedRoutes()]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Loading.loader(context)));
  }
}

import 'package:chatty/features/shared/widgets/app_loading.dart';
import '../constants/exports.dart';

class StateHandler extends StatefulWidget {
  final AppState state;

  /// Main UI builder (screen content)
  final Widget Function(BuildContext context, AppState state) builder;

  /// Optional widgets
  final Widget? loadingWidget;
  final Widget? failureWidget;
  final Widget? loadingOverlayWidget;
  final Widget? emptyWidget;

  /// Side-effect callbacks
  final VoidCallback? onSuccess;
  final VoidCallback? onFailure;
  final VoidCallback? onLoading;

  final VoidCallback? onRetry;

  const StateHandler({
    super.key,
    required this.state,
    required this.builder,
    this.loadingWidget,
    this.failureWidget,
    this.loadingOverlayWidget,
    this.emptyWidget,
    this.onSuccess,
    this.onFailure,
    this.onLoading,
    this.onRetry,
  });

  @override
  State<StateHandler> createState() => _StateHandlerState();
}

class _StateHandlerState extends State<StateHandler> {
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  /* -------------------------------------------------------------------------- */
  /*                               Overlay Logic                                */
  /* -------------------------------------------------------------------------- */

  void _showOverlay() {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (_) => Material(
        color: Colors.black54,
        child: Center(
          child: widget.loadingOverlayWidget ?? Loading.loader(context),
        ),
      ),
    );

    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _handleOverlay() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (widget.state.status == StateStatus.loadingOverlay) {
        _showOverlay();
      } else {
        _removeOverlay();
      }
    });
  }

  /* -------------------------------------------------------------------------- */
  /*                              Side-Effect Hooks                              */
  /* -------------------------------------------------------------------------- */

  void _handleCallbacks() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      switch (widget.state.status) {
        case StateStatus.success:
          widget.onSuccess?.call();
          break;

        case StateStatus.error:
          widget.onFailure?.call();
          break;

        case StateStatus.loading:
        case StateStatus.loadingOverlay:
          widget.onLoading?.call();
          break;

        case StateStatus.initial:
        case StateStatus.none:
          break;
      }
    });
  }

  /* -------------------------------------------------------------------------- */
  /*                                   Build                                    */
  /* -------------------------------------------------------------------------- */

  @override
  Widget build(BuildContext context) {
    _handleOverlay();
    _handleCallbacks();

    switch (widget.state.status) {
      /* --------------------------- RENDER MAIN UI --------------------------- */
      case StateStatus.initial:
      case StateStatus.success:
      case StateStatus.loadingOverlay:
        return widget.builder(context, widget.state);

      /* ------------------------- FULL SCREEN LOADING ------------------------ */
      case StateStatus.loading:
        return widget.loadingWidget ??
            AppScaffold(
              appbarSize: 0,
              showBackButton: false,
              body: Center(child: Loading.loader(context)),
            );

      /* ------------------------------ FAILURE ------------------------------- */
      case StateStatus.error:
        return widget.failureWidget ??
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.state.message ?? 'Something went wrong',
                    textAlign: TextAlign.center,
                  ),
                  if (widget.onRetry != null) ...[
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: widget.onRetry,
                      child: const Text('Retry'),
                    ),
                  ],
                ],
              ),
            );

      /* ------------------------------- EMPTY -------------------------------- */
      case StateStatus.none:
        return widget.emptyWidget ?? const SizedBox.shrink();
    }
  }
}

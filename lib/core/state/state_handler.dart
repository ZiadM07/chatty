import 'package:Chatty/features/shared/widgets/app_gradient_button.dart';
import 'package:Chatty/features/shared/widgets/app_loading.dart';
import '../constants/exports.dart';

class StateHandler extends StatefulWidget {
  final AppState state;

  final Widget Function(BuildContext context, AppState state) builder;

  final Widget? loadingWidget;
  final Widget? failureWidget;
  final Widget? loadingOverlayWidget;
  final Widget? emptyWidget;

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

  @override
  Widget build(BuildContext context) {
    _handleOverlay();
    _handleCallbacks();

    switch (widget.state.status) {
      case StateStatus.initial:
      case StateStatus.success:
      case StateStatus.loadingOverlay:
        return widget.builder(context, widget.state);
      case StateStatus.loading:
        return widget.loadingWidget ??
            AppScaffold(
              appbarSize: 0,
              showBackButton: false,
              body: Center(child: Loading.loader(context)),
            );

      case StateStatus.error:
        return widget.failureWidget ??
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText(
                    widget.state.message ?? context.locale.unexpectedError,
                    align: TextAlign.center,
                  ),
                  if (widget.onRetry != null) ...[
                    const SizedBox(height: 12),
                    AppButton(
                      onTap: widget.onRetry!,
                      text: context.locale.retry,
                      type: AppButtonType.gradient,
                    ),
                  ],
                ],
              ),
            );

      case StateStatus.none:
        return widget.emptyWidget ?? const SizedBox.shrink();
    }
  }
}

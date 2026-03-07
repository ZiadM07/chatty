import '../../../core/constants/exports.dart';
import 'app_widget_direction.dart';

class AppScaffold extends StatefulWidget {
  final Widget body;
  final Widget? appbarChild;
  final Widget? action;
  final String? title;
  final double appbarSize;
  final Color? backgroundColor;
  final void Function()? onBackPress;
  final bool showBackButton;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation floatingActionButtonLocation;
  final bool resizeToAvoidBottomInset;
  final bool extendBodyBehindAppBar;
  final bool showAppBar;
  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.appbarSize = 70.0,
    this.appbarChild,
    this.action,
    this.backgroundColor,
    this.onBackPress,
    this.showBackButton = true,
    this.floatingActionButton,
    this.floatingActionButtonLocation =
        FloatingActionButtonLocation.startDocked,
    this.resizeToAvoidBottomInset = true,
    this.extendBodyBehindAppBar = false,
    this.showAppBar = true,
  });

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: widget.extendBodyBehindAppBar,
      backgroundColor: widget.backgroundColor,
      resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
      appBar: widget.showAppBar
          ? PreferredSize(
              preferredSize: Size(double.infinity, widget.appbarSize),
              child: Container(
                color: widget.backgroundColor ?? context.colorScheme.surface,
                alignment: Alignment.center,
                child: SafeArea(
                  child: Row(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (widget.showBackButton)
                                AppWidgetDirection(
                                  child:
                                      Icon(
                                        SolarIconsOutline.altArrowLeft,
                                        size: 26.0,
                                        color: context.colorScheme.onSurface,
                                      ).addAction(
                                        padding: AppPadding.set(
                                          horizontal: 12.0,
                                        ),
                                        onBounce:
                                            widget.onBackPress ??
                                            () =>
                                                AutoRouterX(context).maybePop(),
                                      ),
                                ),
                              AppText(
                                widget.title ?? "",
                                style: context.textTheme.titleMedium,
                              ).addPadding(start: 8.0),
                            ],
                          ),
                          if (widget.action != null) widget.action!,
                        ],
                      ).addPadding(top: 12.0),
                      if (widget.appbarChild != null)
                        widget.appbarChild!.addPadding(horizontal: 6.0),
                    ],
                  ),
                ),
              ),
            )
          : null,
      body: widget.body,
      floatingActionButton: widget.floatingActionButton,
      floatingActionButtonLocation: widget.floatingActionButtonLocation,
    );
  }
}

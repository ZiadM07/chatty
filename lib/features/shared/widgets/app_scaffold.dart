import '../../../core/constants/exports.dart';
import 'app_widget_direction.dart';

class AppScaffold extends StatelessWidget {
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
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;
  final Widget? drawer;

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
    this.bottomNavigationBar,
    this.bottomSheet,
    this.drawer,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      drawer: drawer,
      appBar: showAppBar ? _buildAppBar(context) : null,
      body: body,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
      bottomSheet: bottomSheet,
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    if (appbarChild != null) {
      return PreferredSize(
        preferredSize: Size(double.infinity, appbarSize),
        child: Container(
          color: backgroundColor ?? context.colorScheme.surface,
          alignment: Alignment.center,
          child: SafeArea(child: appbarChild!.addPadding(horizontal: 6.0)),
        ),
      );
    }

    return PreferredSize(
      preferredSize: Size(double.infinity, appbarSize),
      child: Container(
        color: backgroundColor ?? context.colorScheme.surface,
        alignment: Alignment.center,
        child: SafeArea(
          child: Row(
            children: [
              if (showBackButton)
                AppWidgetDirection(
                  child:
                      Icon(
                        SolarIconsOutline.altArrowLeft,
                        size: 26.0,
                        color: context.colorScheme.onSurface,
                      ).addAction(
                        padding: AppPadding.set(horizontal: 12.0),
                        onBounce:
                            onBackPress ??
                            () => AutoRouterX(context).maybePop(),
                      ),
                ),
              Expanded(
                child: AppText(
                  title ?? "",
                  style: context.textTheme.titleMedium,
                ).addPadding(start: showBackButton ? 8.0 : 16.0),
              ),
              if (action != null) action!.addPadding(end: 12.0),
            ],
          ).addPadding(top: 12.0),
        ),
      ),
    );
  }
}

import 'package:Chatty/core/constants/exports.dart';

class StoryProgressBar extends StatelessWidget {
  final int itemCount;
  final int currentIndex;
  final AnimationController progressController;

  const StoryProgressBar({
    super.key,
    required this.itemCount,
    required this.currentIndex,
    required this.progressController,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(itemCount, (i) {
        return Expanded(
          child: _ProgressSegment(
            isPast: i < currentIndex,
            isCurrent: i == currentIndex,
            controller: i == currentIndex ? progressController : null,
          ),
        );
      }),
    );
  }
}

class _ProgressSegment extends StatelessWidget {
  final bool isPast;
  final bool isCurrent;
  final AnimationController? controller;

  const _ProgressSegment({
    required this.isPast,
    required this.isCurrent,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2.5,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: Colors.white.withValues(alpha: 0.25),
      ),
      clipBehavior: Clip.hardEdge,
      child: isPast
          ? _fill(context, 1.0)
          : isCurrent && controller != null
          ? AnimatedBuilder(
              animation: controller!,
              builder: (_, i) => _fill(context, controller!.value),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _fill(BuildContext context, double fraction) => FractionallySizedBox(
    alignment: Alignment.centerLeft,
    widthFactor: fraction,
    child: DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [context.colorScheme.primary, context.colorScheme.secondary],
        ),
      ),
    ),
  );
}

import 'package:Chatty/core/constants/exports.dart';
import 'package:Chatty/features/main/widgets/nav_item.dart';

class BottomNavWidget extends StatelessWidget {
  final ValueChanged onChanged;
  final List<NavModel> items;
  final int index;

  const BottomNavWidget({
    super.key,
    required this.onChanged,
    required this.items,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 80,
          width: double.infinity,
          decoration: BoxDecoration(
            color: context.colorScheme.outline.withValues(alpha: 0.4),

            borderRadius: AppBorderRadius.set(topStart: 18, topEnd: 18),
          ),
        ),
        Positioned(
          top: -20,
          left: 0,
          right: 0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: items.asMap().entries.map((item) {
              return Expanded(
                child: NavItem(
                  key: ValueKey(item.value.name),
                  isActive: index == item.key,
                  isMiddleItem: item.key == 1,
                  icon: item.value.icon,
                  title: item.value.name,

                  iconSize: 26.0,
                ).addAction(onTap: () => onChanged(item.key)),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class NavModel {
  final String icon, name;

  const NavModel({required this.name, required this.icon});
}

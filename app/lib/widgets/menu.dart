
import "package:flutter/material.dart";
import "package:md_notes/widgets/surface_container.dart";

class MenuDrawer extends InheritedWidget {
  const MenuDrawer({
    super.key,
    required this.menu,
    required super.child,
  });

  final CustomMenu menu;

  static CustomMenu? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MenuDrawer>()?.menu;
  }

  static CustomMenu of(BuildContext context) {
    final CustomMenu? result = maybeOf(context);
    assert(result != null, 'No Custom Menus found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(MenuDrawer oldWidget) => menu != oldWidget.menu;
}

abstract class MenuItem {}

class MenuDivider extends MenuItem {}

class SectionLabel extends MenuItem {
  SectionLabel({required this.label});

  final String label;
}

class MenuDestination extends MenuItem {
  MenuDestination({
    required this.icon,
    required this.path,
    required this.label,
  });

  final String label, path;
  final IconData icon;
}

class MenuAction extends MenuItem {
  MenuAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
}

class CustomMenu extends StatelessWidget {
  CustomMenu({
    this.header,
    required this.items,
    required this.index,
    this.expanded = true,
    required this.onDestinationSelected,
  });

  final int index;
  final bool expanded;
  final Widget? header;
  final List<MenuItem> items;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {

    List<MenuDestination> destinations = List<MenuDestination>.from(
      items.where((item) => item is MenuDestination),
    );

    return SizedBox(
      width: expanded ? 360 : 80,
      height: double.infinity,
      child: SurfaceContainer.low(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (expanded) header ?? SizedBox(),
                SizedBox(
                  height: 24,
                ),
                if (!expanded)
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 12,
                      left: 28.0,
                      right: 28.0,
                      bottom: 32.0,
                    ),
                    child: Icon(Icons.menu),
                  ),
                ...items.map<Widget>((item) {

                  if (item is MenuDestination) {
                    int itemIndex = destinations.indexOf(item);
                    bool isSelected = itemIndex == index;
                    if (expanded) {
                      return DrawerTile(
                        icon: item.icon,
                        label: item.label,
                        selected: isSelected,
                        onTap: () => onDestinationSelected(itemIndex),
                      );
                    } else {
                      return RailTile(
                        icon: item.icon,
                        label: item.label,
                        selected: isSelected,
                        onTap: () => onDestinationSelected(itemIndex),
                      );
                    }
                  }

                  if (expanded) {
                    if (item is MenuAction) {
                      return DrawerTile(
                        icon: item.icon,
                        label: item.label,
                        onTap: item.onTap,
                      );
                    } else if (item is SectionLabel) {
                      return Padding(
                        padding:
                        EdgeInsets.symmetric(vertical: 8, horizontal: 28),
                        child: Text(
                          item.label,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      );
                    } else if (item is MenuDivider) {
                      return Divider(
                        height: 32,
                        indent: 28,
                        endIndent: 28,
                      );
                    }
                  }

                  return SizedBox();
                })
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RailTile extends StatelessWidget {
  RailTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    ColorScheme cScheme = theme.colorScheme;
    TextStyle labelStyle = theme.textTheme.labelMedium!;

    Color backgroundcolor =
    selected ? cScheme.secondaryContainer : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 12.0,
      ),
      child: SizedBox(
        height: 56,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 12,
                right: 12,
                bottom: 4,
              ),
              child: Material(
                color: backgroundcolor,
                borderRadius: BorderRadius.circular(16),
                clipBehavior: Clip.hardEdge,
                child: InkWell(
                  onTap: onTap,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 16,
                    ),
                    child: Icon(
                      icon,
                      color: selected
                          ? cScheme.onSecondaryContainer
                          : cScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
            Text(
              label,
              style: labelStyle.copyWith(
                color: cScheme.onSurfaceVariant,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class DrawerTile extends StatelessWidget {
  DrawerTile({
    this.onTap,
    required this.icon,
    required this.label,
    this.selected = false,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    Color backgroundcolor =
    selected ? colorScheme.secondaryContainer : Colors.transparent;
    TextStyle textStyle = TextStyle(
      color: selected
          ? colorScheme.onSecondaryContainer
          : colorScheme.onSurfaceVariant,
    );

    return SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Material(
          textStyle: textStyle,
          clipBehavior: Clip.hardEdge,
          color: backgroundcolor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: InkWell(
            onTap: onTap,
            splashColor: colorScheme.secondaryContainer,
            child: Builder(builder: (context) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: 16),
                  Icon(icon),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  /*SizedBox(width: 12),
                    Text("24"),
                    SizedBox(width: 24),*/
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
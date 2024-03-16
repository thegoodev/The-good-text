import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:md_notes/widgets/surface_container.dart';

// Medium: 840 Expanded:1200 Extra large: 1600

class NestedNavigator extends StatelessWidget {
  NestedNavigator({
    required this.child,
    required this.state,
  });

  final Widget child;
  final GoRouterState state;

  @override
  Widget build(BuildContext context) {
    print(state.fullPath);

    return AdaptiveNavigation(
      child: child,
    );
  }
}

class AdaptiveNavigation extends StatefulWidget {
  AdaptiveNavigation({
    required this.child,
  });
  final Widget child;

  @override
  State<StatefulWidget> createState() => _AdaptiveNavigationState();
}

class _AdaptiveNavigationState extends State<AdaptiveNavigation> {
  int selectedIndex = 0;
  final routes = ["/home", "/a", "/b", "/account", "/c"];

  updateIndex(int newIndex) {
    setState(() {
      selectedIndex = newIndex;
    });
    context.go(routes[newIndex]);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    print(width);

    if (width <= 840) {
      return Scaffold(appBar: AppBar(), drawer: Drawer(), body: widget.child);
    }

    return Material(
      type: MaterialType.canvas,
      child: Row(
        children: [
          if (width >= 1200)
            SurfaceContainer.low(
              child: SizedBox(
                width: 360,
                child: CustomMenu(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: updateIndex,
                  items: [
                    MenuDestination(
                      label: "Home",
                      icon: Icons.space_dashboard_outlined,
                    ),
                    MenuDestination(
                      label: "Archive",
                      icon: Icons.archive_outlined,
                    ),
                    MenuDestination(
                      label: "Trash",
                      icon: Icons.delete_outline,
                    ),
                    MenuDivider(),
                    SectionLabel(
                      label: "Labels",
                    ),
                    MenuAction(
                      label: "Manage Labels",
                      icon: Icons.new_label_outlined,
                      onTap: () => print("Manage Label"),
                    ),
                    MenuDivider(),
                    MenuDestination(
                      label: "Account",
                      icon: Icons.account_box_outlined,
                    ),
                    MenuDestination(
                      label: "Settings",
                      icon: Icons.settings_outlined,
                    ),
                    MenuAction(
                      label: "Sign Out",
                      icon: Icons.exit_to_app_outlined,
                      onTap: () => print("Signing out"),
                    ),
                  ],
                ),
              ),
            ),
          if (width < 1200)
            SurfaceContainer(
              child: SizedBox(
                width: 80,
                height: double.infinity,
              ),
            ),
          Expanded(
            child: widget.child,
          )
        ],
      ),
    );
  }
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
    required this.label,
  });

  final String label;
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
    required this.items,
    required this.selectedIndex,
    this.onDestinationSelected,
  });

  final int selectedIndex;
  final List<MenuItem> items;
  final ValueChanged<int>? onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    List<MenuDestination> destinations = items
        .where((element) => element is MenuDestination)
        .cast<MenuDestination>()
        .toList();

    return ListView.builder(
      padding: EdgeInsets.only(
        top: 48,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        MenuItem item = items[index];

        if (item is MenuDestination) {
          int destinationIndex = destinations.indexOf(item);

          return DrawerTile(
            icon: item.icon,
            label: item.label,
            selected: selectedIndex == destinationIndex,
            onTap: () => (onDestinationSelected ?? (_) {})(destinationIndex),
          );
        } else if (item is MenuAction) {
          return DrawerTile(
            icon: item.icon,
            label: item.label,
            onTap: item.onTap,
          );
        } else if (item is SectionLabel) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 28),
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

        return SizedBox();
      },
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

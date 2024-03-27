import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:md_notes/widgets/profile.dart';
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
      path: state.fullPath ?? "/home",
    );
  }
}

class AdaptiveNavigation extends StatelessWidget {
  AdaptiveNavigation({
    required this.child,
    required this.path,
  });
  final Widget child;
  final String path;

  go(BuildContext context, String path) {
    context.go(path);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    List<MenuItem> items = [
      MenuDestination(
        label: "Home",
        path: "/",
        icon: Icons.space_dashboard_outlined,
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
        label: "Archive",
        path: "/archive",
        icon: Icons.archive_outlined,
      ),
      MenuDestination(
        label: "Trash",
        path: "/trash",
        icon: Icons.delete_outline,
      ),
      MenuDivider(),
      MenuDestination(
        label: "Account",
        path: "/account",
        icon: Icons.account_box_outlined,
      ),
      MenuDestination(
        label: "Settings",
        path: "/settings",
        icon: Icons.settings_outlined,
      ),
      MenuAction(
        label: "Sign Out",
        icon: Icons.exit_to_app_outlined,
        onTap: () => print("Signing out"),
      ),
    ];

    if (width <= 840) {
      return Scaffold(
        appBar: AppBar(),
        drawer: Padding(
          padding: const EdgeInsets.only(right: 80.0),
          child: CustomMenu(
            expanded: true,
            header: UserProfile(),
            items: items,
            destination: path,
            onDestinationSelected: (path) {
              context.pop();
              go(context, path);
            },
          ),
        ),
        body: child,
      );
    }

    return Material(
      type: MaterialType.canvas,
      child: Row(
        children: [
          CustomMenu(
            expanded: width > 1200,
            header: UserProfile(),
            items: items,
            destination: path,
          ),
          Expanded(
            child: child,
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
    this.expanded = true,
    required this.destination,
    this.onDestinationSelected,
  });

  final Widget? header;
  final bool expanded;
  final String destination;
  final List<MenuItem> items;
  final ValueChanged<String>? onDestinationSelected;

  @override
  Widget build(BuildContext context) {
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
                    bool isSelected =
                        destination.toLowerCase == item.path.toLowerCase;
                    if (expanded) {
                      return DrawerTile(
                        icon: item.icon,
                        label: item.label,
                        selected: isSelected,
                        onTap: () =>
                            (onDestinationSelected ?? (_) {})(item.path),
                      );
                    } else {
                      return RailTile(
                        icon: item.icon,
                        label: item.label,
                        selected: isSelected,
                        onTap: () =>
                            (onDestinationSelected ?? (_) {})(item.path),
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

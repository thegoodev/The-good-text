import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:md_notes/widgets/menu.dart';
import 'package:md_notes/widgets/profile.dart';
import 'package:md_notes/widgets/surface_container.dart';

// Medium: 840 Expanded:1200 Extra large: 1600

class AdaptiveNavigation extends StatelessWidget {
  AdaptiveNavigation({
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  void _handleDestinationSelected(int index){
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {

    int currentIndex = navigationShell.currentIndex;
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
        onTap: () => FirebaseAuth.instance.signOut(),
      ),
    ];

    if (width <= 840) {
      return Material(
        child: SafeArea(
          child: MenuDrawer(
            menu: CustomMenu(
              expanded: true,
              header: UserProfile(),
              items: items,
              index: currentIndex,
              onDestinationSelected: _handleDestinationSelected,
            ),
            child: navigationShell,
          ),
        ),
      );
    }

    return Material(
      type: MaterialType.canvas,
      child: Row(
        children: [
          CustomMenu(
            items: items,
            index: currentIndex,
            expanded: width > 1200,
            onDestinationSelected: _handleDestinationSelected,
          ),
          Expanded(
            child: navigationShell,
          )
        ],
      ),
    );
  }
}

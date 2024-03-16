import 'package:flutter/material.dart';

enum SurfaceRole { lowest, low, container, high, highest }

Map<SurfaceRole, double> elevation = {
  SurfaceRole.lowest: 0,
  SurfaceRole.low: 1,
  SurfaceRole.container: 3,
  SurfaceRole.high: 6,
  SurfaceRole.highest: 0,
};

class SurfaceContainer extends StatelessWidget {
  // 0
  SurfaceContainer.lowest({
    required this.child,
  }) : role = SurfaceRole.lowest;
  // +1
  SurfaceContainer.low({
    required this.child,
  }) : role = SurfaceRole.low;
  // +2
  SurfaceContainer({
    required this.child,
  }) : role = SurfaceRole.container;
  // +3
  SurfaceContainer.high({
    required this.child,
  }) : role = SurfaceRole.high;
  // Surface variant
  SurfaceContainer.highest({
    required this.child,
  }) : role = SurfaceRole.highest;

  final Widget child;
  final SurfaceRole role;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Material(
      elevation: elevation[role] ?? 0,
      type: MaterialType.card,
      color: role == SurfaceRole.highest
          ? colorScheme.surfaceVariant
          : colorScheme.surface,
      shadowColor: Colors.transparent,
      surfaceTintColor: colorScheme.surfaceTint,
      child: DefaultTextStyle(
        style: TextStyle(
          color: colorScheme.onSurface,
        ),
        child: child,
      ),
    );
  }
}

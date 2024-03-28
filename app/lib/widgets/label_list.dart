import 'package:flutter/material.dart';
import 'package:md_notes/widgets/surface_container.dart';

class LabelList extends StatelessWidget {
  LabelList({
    required this.labels,
  });

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    if (labels.isEmpty) {
      return SizedBox();
    }

    return Wrap(
        children: List<Widget>.from(
          labels
            .map<Widget>((label) {
              return SurfaceContainer(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4.0,
                      horizontal: 8.0,
                    ),
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                  borderRadius: BorderRadius.circular(4),
              );
            }
          )
        ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

MarkdownStyleSheet _full = MarkdownStyleSheet();
MarkdownStyleSheet _reduced = MarkdownStyleSheet();

class SliverMarkdown extends MarkdownWidget {
  /// Creates a sliver widget that parses and displays Markdown.
  const SliverMarkdown({
    required String data,
    MarkdownStyleSheet? styleSheet,
  }) : super(
          data: data,
          styleSheet: styleSheet,
        );

  @override
  Widget build(BuildContext context, List<Widget>? children) {
    if (children != null) {
      return SliverList(
        delegate: SliverChildListDelegate(children),
      );
    }

    return SliverToBoxAdapter(
      child: SizedBox(),
    );
  }
}

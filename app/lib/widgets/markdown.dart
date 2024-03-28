import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

MarkdownStyleSheet full(ThemeData theme) {
  TextTheme textTheme = theme.textTheme;
  ColorScheme colorScheme = theme.colorScheme;

  return MarkdownStyleSheet(
    blockquote: textTheme.bodyMedium!.copyWith(
      color: colorScheme.onSecondaryContainer,
    ),
    blockquoteDecoration: BoxDecoration(
      color: colorScheme.secondaryContainer,
      borderRadius: BorderRadius.circular(4.0),
    ),
    horizontalRuleDecoration: BoxDecoration(
      border: Border(
        top: BorderSide(color: colorScheme.outlineVariant),
      ),
    ),
  );
}

MarkdownStyleSheet reduced(ThemeData theme) {
  TextTheme textTheme = theme.textTheme;

  return full(theme).copyWith(
    h1: textTheme.titleMedium,
    h2: textTheme.titleSmall,
    h3: textTheme.bodyLarge,
    h4: textTheme.bodyLarge,
    h5: textTheme.bodyLarge,
    h6: textTheme.bodyLarge,
  );
}

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

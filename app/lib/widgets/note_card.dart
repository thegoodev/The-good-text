import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import 'package:md_notes/models/note.dart';
import 'package:md_notes/widgets/surface_container.dart';

class NoteCard extends StatelessWidget {
  NoteCard({required this.note});

  final Note note;

  String getContent() {
    List paragraphs = note.body.split("\n");
    List preview = [];

    int maxLength = 20, count = 0;

    for (String paragraph in paragraphs) {
      if (paragraph.isNotEmpty && !paragraph.startsWith("#")) {
        final words = paragraph.split(" ");

        if (words.length + count > maxLength) {
          paragraph = words.take(maxLength).join(" ");
          paragraph += "...";
        }

        count += words.length;
      }

      preview.add(paragraph);

      if (count >= maxLength) {
        break;
      }
    }

    return preview.join("\n");
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    TextTheme textTheme = themeData.textTheme;
    ColorScheme colorScheme = themeData.colorScheme;

    return Material(
      color: colorScheme.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: note.isFavorite
              ? colorScheme.primary
              : colorScheme.outlineVariant,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          context.go("/n/${note.id}", extra: note);
        },
        child: Padding(
          padding: EdgeInsets.only(left: 12, right: 12, bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 8),
              //getIcon(context, note.state, showArchived),
              SizedBox(height: 4),
              MarkdownBody(
                data: getContent(),
                styleSheet: MarkdownStyleSheet(
                  listIndent: 12.0,
                  blockSpacing: 4.0,
                  h1: textTheme.titleMedium,
                  h2: textTheme.bodyMedium!
                      .copyWith(fontWeight: FontWeight.bold),
                  h3: textTheme.bodyMedium!
                      .copyWith(fontWeight: FontWeight.bold),
                  h4: textTheme.bodyMedium!
                      .copyWith(fontWeight: FontWeight.bold),
                  h5: textTheme.bodyMedium!
                      .copyWith(fontWeight: FontWeight.bold),
                  h6: textTheme.bodyMedium!
                      .copyWith(fontWeight: FontWeight.bold),
                  horizontalRuleDecoration: BoxDecoration(
                    border: Border(
                      top:
                          BorderSide(width: 1.0, color: themeData.dividerColor),
                    ),
                  ),
                ),
              ),
              _LabelList(
                labels: note.labels,
              )
              //NoteLabelList(note: note, maxLength: 4),
            ],
          ),
        ),
      ),
    );
  }
}

class _LabelList extends StatelessWidget {
  _LabelList({
    required this.labels,
  });

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    if (labels.isEmpty) {
      return SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Wrap(
        children: labels
            .map<Widget>(
              (label) => SurfaceContainer(
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
              ),
            )
            .toList(),
      ),
    );
  }
}

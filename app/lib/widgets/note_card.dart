import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import 'package:md_notes/models/note.dart';

class NoteCard extends StatelessWidget {
  NoteCard({required this.note});

  final NoteModel note;

  String getContent() {
    List paragraphs = note.body.split("\n");
    List preview = [];

    int maxLength = 50, count = 0;

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
          color: colorScheme.outlineVariant,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          context.go("/n/${note.id}", extra: note);
        },
        child: Padding(
          padding: EdgeInsets.only(left: 12, right: 12),
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
                  h1: textTheme.titleSmall,
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
              //NoteLabelList(note: note, maxLength: 4),
              SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

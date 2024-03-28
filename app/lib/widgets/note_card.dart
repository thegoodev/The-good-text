import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import 'package:md_notes/models/note.dart';
import 'package:md_notes/widgets/label_list.dart';
import 'package:md_notes/widgets/markdown.dart';
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
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;
    ColorScheme colorScheme = theme.colorScheme;

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
                styleSheet: reduced(theme),
              ),
              if(note.labels.isNotEmpty)
                SizedBox(height: 8),
              LabelList(
                labels: note.labels,
              )
            ],
          ),
        ),
      ),
    );
  }
}
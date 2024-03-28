import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:md_notes/blocs/note.dart';
import 'package:md_notes/models/note.dart';
import 'package:md_notes/widgets/label_list.dart';
import 'package:md_notes/widgets/markdown.dart';

final FloatingActionButtonLocation _fabLocation =
    FloatingActionButtonLocation.endContained;

class ReadingMode extends StatefulWidget {
  ReadingMode({required this.state});
  final GoRouterState state;

  @override
  State<StatefulWidget> createState() => _ReadingModeState();
}

class _ReadingModeState extends State<ReadingMode> {
  Note? note;
  late Stream<Note?> updates;
  final NoteBloc bloc = NoteBloc();

  @override
  void initState() {
    String id = widget.state.pathParameters["id"]!;
    note = widget.state.extra as Note?;

    updates = bloc.fetchNote(id);

    super.initState();
  }

  String formatDate(DateTime time) {
    DateTime now = DateTime.now();

    String pattern = "MMM dd, yyyy";

    if (now.year == time.year) {
      pattern = "MMM dd";
      if (now.day == time.day) {
        bool is24Hours = MediaQuery.of(context).alwaysUse24HourFormat;

        if (is24Hours) {
          pattern = "HH:mm";
        } else {
          pattern = "hh:mm a";
        }
      }
    }

    return DateFormat(
      pattern,
      Localizations.localeOf(context).toLanguageTag(),
    ).format(time);
  }

  undoSnackbar(Note note, String message){

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          action: SnackBarAction(
            label: "Undo",
            onPressed: () {
              print("Action undone");
              bloc.clearState(note);
            },
          ),
        )
    );

    context.pop();
  }

  toggleArchive(Note note) async {
    await bloc.toggleArchive(note);
    if (!note.isArchived) {
      undoSnackbar(note, "Sent note to archive");
    }
  }

  toggleDelete(Note note) async {
    await bloc.toggleDelete(note);
    if (!note.isDeleted) {
      undoSnackbar(note, "Sent note to trash");
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;
    ColorScheme colors = theme.colorScheme;

    return StreamBuilder<Note?>(
      stream: updates,
      initialData: note,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final Note note = snapshot.data!;

          Icon favoriteIcon = note.isFavorite
              ? const Icon(Icons.favorite)
              : const Icon(Icons.favorite_border);
          Icon archiveIcon = note.isArchived
              ? const Icon(Icons.unarchive_outlined)
              : const Icon(Icons.archive_outlined);
          Icon deletedIcon = note.isDeleted
              ? const Icon(Icons.restore_from_trash_outlined)
              : const Icon(Icons.delete_outline);

          return Scaffold(
            body: SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    floating: true,
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: 4.0,
                        left: 24.0,
                        right: 24.0,
                      ),
                      child: Text(
                        "Edited ${formatDate(note.lastEdit)}",
                        style: textTheme.labelMedium,
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 24.0,
                    ),
                    sliver: SliverMarkdown(
                      data: note.body,
                      styleSheet: full(theme),
                    ),
                  ),
                  SliverPadding(
                      padding: EdgeInsets.only(
                          top: 8.0,
                          left: 24.0,
                          right: 24.0,
                          bottom: 24.0,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: LabelList(
                          labels: note.labels,
                        ),
                      ),
                  ),
                ],
              ),
            ),
            floatingActionButtonLocation: _fabLocation,
            floatingActionButton: FloatingActionButton(
              elevation: 0,
              foregroundColor: colors.onSecondaryContainer,
              backgroundColor: colors.secondaryContainer,
              onPressed: () {
                context.go("/n/${note.id}/edit", extra: note);
              },
              child: Icon(Icons.edit_note),
            ),
            bottomNavigationBar: BottomAppBar(
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.more_vert),
                  ),
                  IconButton(
                    icon: favoriteIcon,
                    onPressed: () => bloc.toggleFavorite(note),
                  ),
                  IconButton(
                    icon: archiveIcon,
                    onPressed: () => toggleArchive(note),
                  ),
                  IconButton(
                    icon: deletedIcon,
                    onPressed: () => toggleDelete(note),
                  )
                ],
              ),
            ),
          );
        }

        return Material(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}

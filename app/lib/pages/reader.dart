import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:md_notes/blocs/note.dart';
import 'package:md_notes/models/note.dart';
import 'package:md_notes/widgets/markdown.dart';

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

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    TextTheme textTheme = themeData.textTheme;
    ColorScheme colors = themeData.colorScheme;

    return StreamBuilder<Note?>(
      stream: updates,
      initialData: note,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final Note note = snapshot.data!;

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
                      styleSheet: MarkdownStyleSheet(
                        horizontalRuleDecoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              width: 1.0,
                              color: colors.outlineVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.endDocked,
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                context.go("/n/${note.id}/edit", extra: note);
              },
              child: Icon(Icons.edit_note),
            ),
            bottomNavigationBar: BottomAppBar(
              height: 56,
              padding: EdgeInsets.symmetric(horizontal: 16),
              shape: CircularNotchedRectangle(),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      note.isFavorite ? Icons.favorite : Icons.favorite_border,
                    ),
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

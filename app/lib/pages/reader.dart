import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:md_notes/blocs/noteBloc.dart';
import 'package:md_notes/models/note.dart';

class ReadingMode extends StatefulWidget {
  ReadingMode({
    required this.id,
    required this.note,
  });
  final String id;
  final NoteModel? note;

  @override
  State<StatefulWidget> createState() => _ReadingModeState();
}

class _ReadingModeState extends State<ReadingMode> {
  NoteBloc bloc = NoteBloc();

  @override
  void initState() {
    bloc.fetchNote(widget.id);
    super.initState();
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
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

    return StreamBuilder<NoteModel?>(
        stream: bloc.note,
        initialData: widget.note,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final NoteModel note = snapshot.data!;

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
                          left: 24,
                          right: 24,
                          top: 24,
                        ),
                        child: Text(
                          "Edited ${formatDate(note.lastEdit)}",
                          style: textTheme.labelMedium,
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 24,
                      ),
                      sliver: MarkdownSliver(
                        data: note.body,
                        styleSheet: MarkdownStyleSheet(
                          p: textTheme.bodyMedium,
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
                child: Icon(Icons.edit),
              ),
              bottomNavigationBar: BottomAppBar(
                height: 56,
                padding: EdgeInsets.symmetric(horizontal: 16),
                shape: CircularNotchedRectangle(),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.favorite_border_outlined),
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
        });
  }
}

class MarkdownSliver extends MarkdownWidget {
  /// Creates a sliver widget that parses and displays Markdown.
  const MarkdownSliver({
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

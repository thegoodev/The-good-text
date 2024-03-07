import 'package:flutter/material.dart';
import 'package:md_notes/auth.dart';
import 'package:md_notes/note.dart';
import 'package:md_notes/profile.dart';
import 'package:md_notes/ui.dart';
import 'package:provider/provider.dart';

import 'package:flutter_i18n/flutter_i18n.dart';

GlobalKey<ScaffoldState> archiveScaffold = GlobalKey<ScaffoldState>();

class Archive extends StatefulWidget {
  Archive();

  @override
  _ArchiveState createState() => _ArchiveState();
}

class _ArchiveState extends State<Archive> {
  @override
  Widget build(BuildContext context) {
    Widget layout = Scaffold(
        key: archiveScaffold,
        body: SafeArea(
          child: Consumer<GoodUser>(
            builder: (context, user, child) {
              List<Note> notes = user.archive;

              if (notes == null) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              NoteSource source =
                  NoteSource(key: archiveScaffold, name: "/archive");
              notes.forEach((note) {
                note.source = source;
              });

              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    title: I18nText("Archive", child: Text("")),
                    actions: [
                      OfflineIndicator(),
                      ToggleGrid(show: notes.length > 0, user: user)
                    ],
                  ),
                  EmptySliver(
                    show: notes.length == 0,
                    name: "filling_system",
                    body: "Nothing in archive",
                  ),
                  NoteGridList(
                    grid: user.grid,
                    notes: notes,
                  )
                ],
              );
            },
          ),
        ));

    return Responsive(
      bigChild: BigLayout(
        left: Profile(standalone: false),
        right: layout,
      ),
      child: layout,
    );
  }
}

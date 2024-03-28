import 'package:flutter/material.dart';
import 'package:md_notes/blocs/archive.dart';
import 'package:md_notes/models/note.dart';
import 'package:md_notes/widgets/note_list.dart';

import '../widgets/menu.dart';

GlobalKey<ScaffoldState> archiveScaffold = GlobalKey<ScaffoldState>();

class Archive extends StatefulWidget {
  Archive();

  @override
  _ArchiveState createState() => _ArchiveState();
}

class _ArchiveState extends State<Archive> {
  ArchiveBloc bloc = ArchiveBloc();

  @override
  Widget build(BuildContext context) {

    CustomMenu? menu = MenuDrawer.maybeOf(context);

    return StreamBuilder<List<Note>>(
      stream: bloc.notes,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Note> notes = snapshot.data!;

          return Scaffold(
            drawer: menu,
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  title: Text("Archive"),
                ),
                NoteList(notes: notes),
              ],
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

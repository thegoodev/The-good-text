import 'package:flutter/material.dart';
import 'package:md_notes/models/note.dart';

GlobalKey<ScaffoldState> archiveScaffold = GlobalKey<ScaffoldState>();

class Archive extends StatefulWidget {
  Archive();

  @override
  _ArchiveState createState() => _ArchiveState();
}

class _ArchiveState extends State<Archive> {
  List<NoteModel> notes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: archiveScaffold,
      body: SafeArea(
        child: Builder(
          builder: (context) {
            if (notes == null) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            /*NoteSource source =
                NoteSource(key: archiveScaffold, name: "/archive");
            notes.forEach((note) {
              note.source = source;
            });*/

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  title: Text("Archive"),
                ),
                /*
                EmptySliver(
                  show: notes.length == 0,
                  name: "filling_system",
                  body: "Nothing in archive",
                ),
                */
                //Note list notes
              ],
            );
          },
        ),
      ),
    );
  }
}

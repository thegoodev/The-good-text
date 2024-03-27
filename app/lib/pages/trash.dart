import 'package:flutter/material.dart';
import 'package:md_notes/blocs/archive.dart';
import 'package:md_notes/blocs/trash.dart';
import 'package:md_notes/models/note.dart';
import 'package:md_notes/widgets/note_list.dart';

GlobalKey<ScaffoldState> archiveScaffold = GlobalKey<ScaffoldState>();

class Trash extends StatefulWidget {
  Trash();

  @override
  _ArchiveState createState() => _ArchiveState();
}

class _ArchiveState extends State<Trash> {
  TrashBloc bloc = TrashBloc();

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    print(colorScheme.primaryContainer);
    print(colorScheme.secondary);

    return StreamBuilder<List<Note>>(
      stream: bloc.notes,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Note> notes = snapshot.data!;

          return Material(
            child: CustomScrollView(
              slivers: [
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

/*GlobalKey<ScaffoldState> trashScaffold = GlobalKey<ScaffoldState>();

class Trash extends StatefulWidget {
  Trash();

  @override
  _TrashState createState() => _TrashState();
}

class _TrashState extends State<Trash> {
  @override
  Widget build(BuildContext context) {
    List<Note> notes = [];

    return Scaffold(
      key: trashScaffold,
      body: SafeArea(
        child: Builder(
          builder: (context) {
            /*NoteSource source = NoteSource(key: trashScaffold, name: "/trash");
            notes.forEach((note) {
              note.source = source;
            });*/

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  title: Text("Trash"),
                  actions: [
                    notes.length > 0
                        ? PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == "Delete All") {
                                WriteBatch batch =
                                    FirebaseFirestore.instance.batch();
                                /*notes.forEach((element) {
                                  batch.delete(element.ref);
                                });
                                batch.commit();*/
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem<String>(
                                value: "Delete All",
                                child: Text("Empty Trash"),
                              )
                            ],
                          )
                        : SizedBox()
                  ],
                ),
                SliverToBoxAdapter(
                  child: notes.length == 0
                      ? SizedBox()
                      : Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                              "Items in trash will be permanetly deleted after 7 days"),
                        ),
                ),
                /*EmptySliver(
                  show: notes.length == 0,
                  name: "throw_away",
                  title: "Nothing in trash",
                  body:
                      "Items in trash will be permanently deleted after 7 days",
                ),
                NoteGrid(
                  notes: notes,
                )*/
              ],
            );
          },
        ),
      ),
    );
  }
}*/
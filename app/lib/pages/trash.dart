import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:md_notes/models/note.dart';
import 'package:md_notes/ui.dart';

GlobalKey<ScaffoldState> trashScaffold = GlobalKey<ScaffoldState>();

class Trash extends StatefulWidget {
  Trash();

  @override
  _TrashState createState() => _TrashState();
}

class _TrashState extends State<Trash> {
  @override
  Widget build(BuildContext context) {
    List<NoteModel> notes = [];

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
}

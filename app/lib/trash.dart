import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:md_notes/auth.dart';
import 'package:md_notes/note.dart';
import 'package:md_notes/profile.dart';
import 'package:md_notes/ui.dart';
import 'package:provider/provider.dart';

import 'package:flutter_i18n/flutter_i18n.dart';

GlobalKey<ScaffoldState> trashScaffold = GlobalKey<ScaffoldState>();

class Trash extends StatefulWidget {
  Trash({Key key}) : super(key: key);

  @override
  _TrashState createState() => _TrashState();
}

class _TrashState extends State<Trash> {

  @override
  Widget build(BuildContext context) {
    Widget layout = Scaffold(
      key: trashScaffold,
      body: SafeArea(
        child: Consumer<GoodUser>(
          builder: (context, value, child) {
            List<Note> notes = value.trash;

            if(notes==null){
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            NoteSource source = NoteSource(key: trashScaffold, name: "/trash");
            notes.forEach((note){note.source = source;});

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  title: I18nText("Trash"),
                  actions: [
                    notes.length>0?PopupMenuButton<String>(
                      onSelected: (value) {
                        if(value=="Delete All"){
                          WriteBatch batch = FirebaseFirestore.instance.batch();
                          notes.forEach((element){batch.delete(element.ref);});
                          batch.commit();
                        }
                      },
                      itemBuilder: (context)=>[
                        PopupMenuItem<String>(
                          value: "Delete All",
                          child: I18nText("Empty Trash",child:Text(""))
                        )
                      ]
                    ):SizedBox()
                  ],
                ),
                SliverToBoxAdapter(
                  child: notes.length==0?SizedBox():child,
                ),
                EmptySliver(
                  show: notes.length==0,
                  name: "throw_away",
                  title: "Nothing in trash",
                  body: "Items in trash will be permanently deleted after 7 days",
                ),
                NoteGrid(
                  notes: notes,
                )
              ],
            );
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: I18nText("Items in trash will be permanetly deleted after 7 days"),
          ),
        )
      )
    );

    return Responsive(
      bigChild: BigLayout(
        left: Profile(standalone: false),
        right: layout,
      ),
      child: layout,
    );
  }
}             
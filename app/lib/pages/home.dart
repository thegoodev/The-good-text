import 'package:flutter/material.dart';
import 'package:md_notes/models/note.dart';
import 'package:md_notes/blocs/homeBloc.dart';
import 'package:md_notes/widgets/note_card.dart';
import 'package:md_notes/widgets/profile_pic.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final NoteListBloc bloc = NoteListBloc();

  @override
  void initState() {
    super.initState();
    bloc.fetchAllNotes();
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<List<NoteModel>>(
          stream: bloc.allNotes,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final List<NoteModel> notes = snapshot.data!;

              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(16.0),
                    sliver: SliverMasonryGrid.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                      childCount: notes.length,
                      itemBuilder: (context, index) {
                        return NoteCard(note: notes[index]);
                      },
                    ),
                  ),
                ],
              );
            }

            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}

class UserHeader extends StatelessWidget {
  UserHeader();

  @override
  Widget build(BuildContext context) {
    User user = FirebaseAuth.instance.currentUser!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ProfilePic(
          size: 40,
          url: user.photoURL,
          margin: EdgeInsets.zero,
        ),
        SizedBox(width: 16),
        Expanded(
          child: Text(
            "Hey, ${user.displayName ?? "".split(" ")[0]}",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}

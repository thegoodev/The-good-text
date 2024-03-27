import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:md_notes/models/note.dart';
import 'package:md_notes/blocs/home.dart';
import 'package:md_notes/widgets/note_card.dart';
import 'package:md_notes/widgets/note_list.dart';
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
    bloc.fetchMainNotes();
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  Future<void> createNote() async {
    Note note = await bloc.createNote();
    print(note);
    context.go("/n/${note.id}/edit", extra: note);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Note>>(
      stream: bloc.notes,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final List<Note> notes = snapshot.data!;

          return Scaffold(
            body: RefreshIndicator(
              onRefresh: bloc.fetchMainNotes,
              child: CustomScrollView(
                slivers: [NoteList(notes: notes)],
              ),
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: createNote,
              icon: Icon(Icons.add),
              label: Text("New Note"),
            ),
          );
        }

        return Center(
          child: CircularProgressIndicator(),
        );
      },
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

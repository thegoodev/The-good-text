import 'package:flutter/material.dart';
import 'package:md_notes/models/note.dart';
import 'package:md_notes/widgets/note_card.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class NoteList extends StatelessWidget {
  NoteList({
    required this.notes,
  });

  final List<Note> notes;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 16.0,
      ),
      sliver: SliverMasonryGrid.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 8.0,
        childCount: notes.length,
        itemBuilder: (context, index) {
          return NoteCard(note: notes[index]);
        },
      ),
    );
  }
}

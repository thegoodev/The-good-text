import 'dart:async';

import 'package:md_notes/resources/notes_provider.dart';

import '../models/note.dart';

class NoteBloc {
  final _repository = NotesProvider();

  Stream<Note?> fetchNote(String id) => _repository.noteUpdates(id);
  
  Future<void> _toggleState(Note note, NoteState state) async {
    if (note.state == state) {
      await clearState(note);
    } else {
      await _repository.updateNoteState(note.id, state);
    }
  }

  Future<void> toggleFavorite(Note note) async {
    await _toggleState(note, NoteState.favorite);
  }

  Future<void> toggleArchive(Note note) async {
    _toggleState(note, NoteState.archived);
  }

  Future<void> toggleDelete(Note note) async {
    _toggleState(note, NoteState.deleted);
  }
  
  Future<void> clearState(Note note) => _repository.updateNoteState(note.id, NoteState.normal);
}

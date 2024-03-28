import 'dart:async';

import 'package:md_notes/models/note.dart';
import 'package:md_notes/resources/notes_provider.dart';

class ArchiveBloc {
  final _repository = NotesProvider();

  Stream<List<Note>> get notes =>
      _repository.notesWithStateUpdates(NoteState.archived);
}

import 'dart:async';

import 'package:md_notes/resources/notes_provider.dart';

import '../models/note.dart';

class NoteBloc {
  final _repository = NotesProvider();

  Stream<Note?> fetchNote(String id) => _repository.syncNote(id);
}

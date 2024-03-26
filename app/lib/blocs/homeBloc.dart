import 'dart:async';

import 'package:md_notes/resources/notes_provider.dart';

import '../models/note.dart';

class NoteListBloc {
  final _repository = NotesProvider();
  final _notesFetcher = StreamController<List<NoteModel>>();

  Stream<List<NoteModel>> get allNotes => _notesFetcher.stream;

  fetchAllNotes() async {
    List<NoteModel> notes = await _repository.fetchMainNotes();
    _notesFetcher.add(notes);
  }

  dispose() {
    _notesFetcher.close();
  }
}

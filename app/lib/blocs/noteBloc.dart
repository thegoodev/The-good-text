import 'dart:async';

import 'package:md_notes/resources/notes_provider.dart';

import '../models/note.dart';

class NoteBloc  {
    final _repository = NotesProvider();
    final _notesFetcher = StreamController<NoteModel?>();

    Stream<NoteModel?> get note => _notesFetcher.stream;

    fetchNote(String id) async {
        NoteModel? note = await _repository.fetchNote(id);
        _notesFetcher.add(note);
    }

    dispose(){
        _notesFetcher.close();
    }
}
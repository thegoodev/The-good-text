import 'dart:async';

import 'package:md_notes/resources/notes_provider.dart';

import '../models/note.dart';

class NoteListBloc {
  NotesProvider _provider = NotesProvider();
  StreamSubscription<List<Note>>? _subscription;
  StreamController<List<Note>> _controller = StreamController();

  Stream<List<Note>> get notes => _controller.stream;

  Future<void> fetchMainNotes() async {
    if (_subscription == null) {
      _subscription = _provider.mainNotesUpdates().listen(
        (event) {
          _controller.add(event);
        },
      );
    } else {
      _controller.add(await _provider.fetchMainNotes());
    }
  }

  Future<Note> createNote() async => _provider.createNote();

  dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}

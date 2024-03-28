enum NoteState {
  favorite,
  normal,
  archived,
  deleted,
}

class Note {
  NoteState state;
  List<String> labels;
  late DateTime lastEdit;
  String body, id, author;

  Note({
    required this.id,
    required this.author,
    this.body = "",
    DateTime? lastEdit,
    this.labels = const [],
    this.state = NoteState.normal,
  }) {
    this.lastEdit = lastEdit ?? DateTime.now();
  }

  bool get isFavorite => state == NoteState.favorite;
  bool get isArchived => state == NoteState.archived;
  bool get isDeleted => state == NoteState.deleted;
}

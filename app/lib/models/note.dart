class NoteModel {
  String body,id, author;
  DateTime lastEdit;

  NoteModel({
    required this.id,
    required this.body,
    required this.author,
    required this.lastEdit,
  });
}
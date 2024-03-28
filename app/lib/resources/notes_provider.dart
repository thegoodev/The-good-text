import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:md_notes/models/note.dart';

final User? _user = FirebaseAuth.instance.currentUser;

Note fromFirestore(DocumentSnapshot snapshot, SnapshotOptions? options) {
  return Note(
    id: snapshot.id,
    body: snapshot.get("body") as String,
    author: snapshot.get("author") as String,
    lastEdit: (snapshot.get("last_edit") as Timestamp).toDate(),
    state: NoteState.values[snapshot.get("state")],
    labels: List<String>.from(snapshot.get("labels")),
  );
}

Map<String, Object> toFirestore(Note note, SetOptions? options) {
  return {
    "body": note.body,
    "author": note.author,
    "labels": note.labels,
    "state": note.state.index,
    "last_edit": Timestamp.fromDate(note.lastEdit),
  };
}

class NotesProvider {
  CollectionReference<Note> _notesRef = FirebaseFirestore.instance
      .collection("users/${_user!.uid}/notes")
      .withConverter<Note>(
        fromFirestore: fromFirestore,
        toFirestore: toFirestore,
      );

  // Create operations

  Future<Note> createNote() async {
    DocumentReference ref = _notesRef.doc();

    Note note = Note(
      id: ref.id,
      author: _user!.uid,
    );

    ref.set(note);

    return note;
  }

  // Read Operations

  Query<Note> get _mainNotesQuery => _notesRef
      .where("state", whereIn: [
        NoteState.favorite.index,
        NoteState.normal.index,
      ])
      .orderBy("state")
      .orderBy("last_edit", descending: true);

  Future<List<Note>> fetchMainNotes() async {
    QuerySnapshot<Note> snapshot = await _mainNotesQuery.get();
    return snapshot.docs.map<Note>((qs) => qs.data()).toList();
  }

  Stream<List<Note>> mainNotesUpdates() => _mainNotesQuery
      .snapshots()
      .map((qs) => qs.docs.map<Note>((doc) => doc.data()).toList());

  Future<List<Note>> fetchNotesWithState(NoteState state) async {
    late Query<Note> query = _notesRef
        .where("state", isEqualTo: state)
        .orderBy("last_edit", descending: true);

    QuerySnapshot<Note> snapshot = await query.get();
    return snapshot.docs.map<Note>((qs) => qs.data()).toList();
  }

  Stream<List<Note>> notesWithStateUpdates(NoteState state) => _notesRef
      .where("state", isEqualTo: state.index)
      .orderBy("last_edit", descending: true)
      .snapshots()
      .map((qs) => qs.docs.map<Note>((doc) => doc.data()).toList());

  Future<Note?> fetchNote(String id) async {
    return (await _notesRef.doc(id).get()).data();
  }

  Stream<Note?> noteUpdates(String id) =>
      _notesRef.doc(id).snapshots().map<Note?>((snapshot) => snapshot.data());

  // Update operations

  Future<void> updateNoteState(String id, NoteState state) async {
    try {
      await _notesRef.doc(id).update({"state": state.index});
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateNoteBody(String id, String body) async {
    if (body.isNotEmpty) {
      try {
        await _notesRef.doc(id).update({
          "body": body,
          "last_edit": FieldValue.serverTimestamp(),
        });
      } catch (e) {
        print(e);
      }
    }
  }

  // Delete operations
}

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/note.dart';

class NotesProvider {
  User? user = FirebaseAuth.instance.currentUser;

  Future<List<NoteModel>> fetchMainNotes() async {
    
    List<NoteModel> notes = [];
    
    if(user!=null){
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection("users/${user!.uid}/notes").get();
      notes = snapshot.docs.map((doc){
        return NoteModel(
          id: doc.id,
          body: doc.get("body") as String,
          author: doc.get("author") as String,
          lastEdit: (doc.get("last_edit") as Timestamp).toDate(),
        );
      }).toList();
    }

    return notes;
  }

  Future<NoteModel?> fetchNote(String id) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.doc("users/${user!.uid}/notes/${id}").get();
    if(doc.exists){
      return NoteModel(
        id: doc.id,
        body: doc.get("body") as String,
        author: doc.get("author") as String,
        lastEdit: (doc.get("last_edit") as Timestamp).toDate(),
      );
    }

    return null;
  }
}
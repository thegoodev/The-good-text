import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:md_notes/models/user.dart';

class UserProvider {
  static Future<GoodUser?> fetchUser(String uid) async {
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.doc("users/${uid}").get();

    if (snapshot.exists) {
      return GoodUser(
        uid: uid,
        photoUrl: snapshot.get("photo") as String,
        displayName: snapshot.get("name") as String,
        description: snapshot.get("description") as String,
      );
    }

    return null;
  }
}

import 'dart:async';

import 'package:md_notes/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:md_notes/resources/user_provider.dart';

class UserBloc {
  final _controller = StreamController<GoodUser>();

  Stream<GoodUser> get user => _controller.stream;

  fetchDetails() async {
    User? fUser = FirebaseAuth.instance.currentUser;

    if (fUser != null) {
      GoodUser? user = await UserProvider.fetchUser(fUser.uid);

      if (user != null) {
        _controller.add(user);
      }
    }
  }

  dispose() {
    _controller.close();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../widgets/header.dart';

class Login extends StatefulWidget {
  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  bool obscureText = true, loading = false, remember = false;
  String? error;

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  login() async {
    setState(() {
      loading = true;
    });

    User? user;

    try {
      FirebaseAuth auth = FirebaseAuth.instance;

      if (kIsWeb) {
        if (remember) {
          await auth.setPersistence(Persistence.LOCAL);
        } else {
          await auth.setPersistence(Persistence.NONE);
        }
      }

      user = (await auth.signInWithEmailAndPassword(
              email: email.text.trim(), password: password.text))
          .user;
    } on FirebaseAuthException catch (e) {
      error = e.message;
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }

    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CoolHeader(
        text: "Welcome Back",
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: error != null ? Text(error!) : SizedBox(),
          ),
          SizedBox(height: 16),
          TextField(
            controller: email,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
                prefixIcon: Icon(Icons.mail_outline),
                hintText: "Email"),
          ),
          SizedBox(height: 16),
          TextField(
            obscureText: obscureText,
            controller: password,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
                prefixIcon: Icon(Icons.lock_outline),
                suffixIcon: GestureDetector(
                    onTap: () => setState(() {
                          obscureText = !obscureText;
                        }),
                    child: Icon(
                        obscureText ? Icons.visibility : Icons.visibility_off)),
                hintText: "Password"),
          ),
          Row(
            children: [
              kIsWeb
                  ? Expanded(
                      child: Row(
                        children: [
                          Checkbox(
                              value: remember,
                              onChanged: (value) {
                                setState(() {
                                  if (value != null) {
                                    remember = value;
                                  }
                                });
                              }),
                          Text("Remember me")
                        ],
                      ),
                    )
                  : SizedBox(),
            ],
          ),
          SizedBox(height: 24),
          FilledButton(onPressed: login, child: Text("Login")),
          SizedBox(height: 16),
          loading ? LinearProgressIndicator() : SizedBox()
        ],
      ),
    );
  }
}

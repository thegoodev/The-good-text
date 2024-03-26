import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:md_notes/models/note.dart';
import 'package:md_notes/pages/account.dart';
import 'package:md_notes/pages/editor.dart';
import 'package:md_notes/pages/home.dart';
import 'package:md_notes/pages/login.dart';
import 'package:md_notes/pages/reader.dart';
import 'package:md_notes/widgets/navigator.dart';
import 'firebase_options.dart';

GlobalKey<MyAppState> appKey = GlobalKey<MyAppState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp(appKey));
}

const purple = Color(0xFF440DB7);
const lightPurple = Color(0xFFad87ff);
const lighterPurple = Color(0xFFBD9EFF);

final GlobalKey<NavigatorState> _rootNavKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  MyApp(Key? key) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  ThemeMode mode = ThemeMode.system;

  setMode(ThemeMode _mode) {
    setState(() {
      mode = _mode;
    });
  }

  final _router = GoRouter(
    navigatorKey: _rootNavKey,
    initialLocation: "/",
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return NestedNavigator(
            child: child,
            state: state,
          );
        },
        routes: [
          GoRoute(
            path: "/",
            builder: (context, state) {
              return HomePage();
            },
            routes: <RouteBase>[
              GoRoute(
                path: "n/:id",
                parentNavigatorKey: _rootNavKey,
                builder: (context, state) {
                  String id = state.pathParameters["id"]!;
                  NoteModel? note = state.extra as NoteModel?;
                  return ReadingMode(
                    id: id,
                    note: note,
                  );
                },
                routes: <RouteBase>[
                  GoRoute(
                    path: "edit",
                    parentNavigatorKey: _rootNavKey,
                    builder: (context, state) {
                      NoteModel? note = state.extra as NoteModel?;

                      if (note != null) {
                        return Editor(note: note);
                      }

                      return SizedBox();
                    },
                  )
                ],
              ),
            ],
          ),
          GoRoute(
            path: "/archive",
            builder: (context, state) {
              return Container(color: Colors.blue);
            },
          ),
          GoRoute(
            path: "/trash",
            builder: (context, state) {
              return Container(color: Colors.purple);
            },
          ),
          GoRoute(
            path: "/account",
            builder: (context, state) {
              return Account();
            },
          ),
          GoRoute(
            path: "/settings",
            builder: (context, state) {
              return Container(color: Colors.green);
            },
          ),
        ],
      ),
      GoRoute(
        path: "/d",
        builder: (context, state) {
          return Container(color: Colors.amber);
        },
      ),
      GoRoute(
        path: "/login",
        builder: (context, state) => Login(),
      ),
    ],
    redirect: (context, state) {
      if (FirebaseAuth.instance.currentUser == null) {
        return '/login';
      } else {
        return null;
      }
    },
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'The Good Text',
      themeMode: ThemeMode.dark,
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xff543c70),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF543c70),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}

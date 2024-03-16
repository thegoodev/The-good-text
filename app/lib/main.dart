import 'dart:async';
import 'dart:js';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:md_notes/pages/account.dart';
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

  runApp(MyApp(key: appKey));
}

const purple = Color(0xFF440DB7);
const lightPurple = Color(0xFFad87ff);
const lighterPurple = Color(0xFFBD9EFF);

class MyApp extends StatefulWidget {
  MyApp({required Key key}) : super(key: key);

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
    initialLocation: "/account",
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
            name: "Home",
            path: "/home",
            builder: (context, state) {
              return HomePage();
            },
          ),
          GoRoute(
            name: "Archive",
            path: "/archive",
            builder: (context, state) {
              return Container(color: Colors.blue);
            },
          ),
          GoRoute(
            name: "Trash",
            path: "/trash",
            builder: (context, state) {
              return Container(color: Colors.purple);
            },
          ),
          GoRoute(
            name: "Account",
            path: "/account",
            builder: (context, state) {
              return Account();
            },
          ),
          GoRoute(
            name: "Settings",
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
        path: "/n/:id",
        builder: (context, state) {
          return ReadingMode(id: state.pathParameters["id"]!);
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
          seedColor: Color(0xFF440DB7),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF440DB7),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}

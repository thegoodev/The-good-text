import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:md_notes/router.dart';
import 'firebase_options.dart';

const purple = Color(0xFF440DB7);
const lightPurple = Color(0xFFad87ff);
const lighterPurple = Color(0xFFBD9EFF);

GlobalKey<MyAppState> appKey = GlobalKey<MyAppState>();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp(appKey));
}

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
      routerConfig: router,
    );
  }
}

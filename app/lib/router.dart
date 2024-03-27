import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'package:md_notes/pages/account.dart';
import 'package:md_notes/pages/archive.dart';
import 'package:md_notes/pages/editor.dart';
import 'package:md_notes/pages/home.dart';
import 'package:md_notes/pages/login.dart';
import 'package:md_notes/pages/reader.dart';
import 'package:md_notes/pages/trash.dart';
import 'package:md_notes/widgets/navigator.dart';

import 'package:firebase_auth/firebase_auth.dart';

final GlobalKey<NavigatorState> _rootNavKey = GlobalKey<NavigatorState>();

final router = GoRouter(
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
                return ReadingMode(state: state);
              },
              routes: <RouteBase>[
                GoRoute(
                  path: "edit",
                  parentNavigatorKey: _rootNavKey,
                  builder: (context, state) {
                    return Editor(state: state);
                  },
                )
              ],
            ),
          ],
        ),
        GoRoute(
          path: "/archive",
          builder: (context, state) {
            return Archive();
          },
        ),
        GoRoute(
          path: "/trash",
          builder: (context, state) {
            return Trash();
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
      path: "/login",
      builder: (context, state) => Login(),
    ),
  ],
  redirect: (context, state) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return '/login';
    } else {
      return null;
    }
  },
);

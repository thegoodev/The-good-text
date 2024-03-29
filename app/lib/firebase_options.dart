// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCZofyRA8gZIBfR6A7ZJaq01GzhkU7wcgM',
    appId: '1:237457989005:web:f6b174abc8e00e330331c4',
    messagingSenderId: '237457989005',
    projectId: 'the-good-text-ef33a',
    authDomain: 'the-good-text-ef33a.firebaseapp.com',
    databaseURL: 'https://the-good-text-ef33a.firebaseio.com',
    storageBucket: 'the-good-text-ef33a.appspot.com',
    measurementId: 'G-Y4T0W1WGXW',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD_9_rMObinVdGKyU3DpGaN6RYbbl3unig',
    appId: '1:237457989005:android:3a418c7f0716d5640331c4',
    messagingSenderId: '237457989005',
    projectId: 'the-good-text-ef33a',
    databaseURL: 'https://the-good-text-ef33a.firebaseio.com',
    storageBucket: 'the-good-text-ef33a.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC22e9trTbzwVu186T1nIYho-cbofiJSWc',
    appId: '1:237457989005:ios:0411068cff684c950331c4',
    messagingSenderId: '237457989005',
    projectId: 'the-good-text-ef33a',
    databaseURL: 'https://the-good-text-ef33a.firebaseio.com',
    storageBucket: 'the-good-text-ef33a.appspot.com',
    iosBundleId: 'com.example.mdNotes',
  );
}

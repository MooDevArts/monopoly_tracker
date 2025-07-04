// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBTCK8Dset9ZBprujD9DAosMra8-IUU-0s',
    appId: '1:559609418737:android:a2883efaaa8eee69e9aa50',
    messagingSenderId: '559609418737',
    projectId: 'monopoly-tracker-153c3',
    databaseURL: 'https://monopoly-tracker-153c3-default-rtdb.firebaseio.com',
    storageBucket: 'monopoly-tracker-153c3.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA2Z8H1iuGoz5qhMpa-WeEfmMAps1mhWj0',
    appId: '1:559609418737:ios:430d9299236db983e9aa50',
    messagingSenderId: '559609418737',
    projectId: 'monopoly-tracker-153c3',
    databaseURL: 'https://monopoly-tracker-153c3-default-rtdb.firebaseio.com',
    storageBucket: 'monopoly-tracker-153c3.firebasestorage.app',
    iosBundleId: 'com.example.monopolyTracker.RunnerTests',
  );

}
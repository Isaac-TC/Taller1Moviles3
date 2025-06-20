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
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyCdRYFm_7h1JMCcaObRjLRE87zHqalYxZ4',
    appId: '1:765214815459:web:a65cf880e1cf7a251cc1d6',
    messagingSenderId: '765214815459',
    projectId: 'taller1moviles3',
    authDomain: 'taller1moviles3.firebaseapp.com',
    databaseURL: 'https://taller1moviles3-default-rtdb.firebaseio.com',
    storageBucket: 'taller1moviles3.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDYNLcOp3zFrFJ77aeyeoN_fn-ORYbYgTc',
    appId: '1:765214815459:android:10c077a4074141a01cc1d6',
    messagingSenderId: '765214815459',
    projectId: 'taller1moviles3',
    databaseURL: 'https://taller1moviles3-default-rtdb.firebaseio.com',
    storageBucket: 'taller1moviles3.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCOK-ibGUhNHOvPEHb-sOrD6LVP0Ps8QLE',
    appId: '1:765214815459:ios:3ab6ae2b8450134c1cc1d6',
    messagingSenderId: '765214815459',
    projectId: 'taller1moviles3',
    databaseURL: 'https://taller1moviles3-default-rtdb.firebaseio.com',
    storageBucket: 'taller1moviles3.firebasestorage.app',
    iosBundleId: 'com.example.taller01',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCOK-ibGUhNHOvPEHb-sOrD6LVP0Ps8QLE',
    appId: '1:765214815459:ios:3ab6ae2b8450134c1cc1d6',
    messagingSenderId: '765214815459',
    projectId: 'taller1moviles3',
    databaseURL: 'https://taller1moviles3-default-rtdb.firebaseio.com',
    storageBucket: 'taller1moviles3.firebasestorage.app',
    iosBundleId: 'com.example.taller01',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCdRYFm_7h1JMCcaObRjLRE87zHqalYxZ4',
    appId: '1:765214815459:web:ad8052dd86ce659f1cc1d6',
    messagingSenderId: '765214815459',
    projectId: 'taller1moviles3',
    authDomain: 'taller1moviles3.firebaseapp.com',
    databaseURL: 'https://taller1moviles3-default-rtdb.firebaseio.com',
    storageBucket: 'taller1moviles3.firebasestorage.app',
  );
}

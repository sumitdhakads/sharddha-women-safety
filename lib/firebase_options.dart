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
    apiKey: 'AIzaSyBL1z2ojDG47JOzHwlS9v4V35UvlLbkvOE',
    appId: '1:902999392028:web:8c56a84f1f3001d23c44d9',
    messagingSenderId: '902999392028',
    projectId: 'shraddha-ab5ad',
    authDomain: 'shraddha-ab5ad.firebaseapp.com',
    databaseURL: 'https://shraddha-ab5ad-default-rtdb.firebaseio.com',
    storageBucket: 'shraddha-ab5ad.firebasestorage.app',
    measurementId: 'G-Y7QXFX9654',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCgGwFRS7q2hCv6AoCEIbr-qTLb2eoaMUI',
    appId: '1:902999392028:android:102e3ad67f2e0e853c44d9',
    messagingSenderId: '902999392028',
    projectId: 'shraddha-ab5ad',
    databaseURL: 'https://shraddha-ab5ad-default-rtdb.firebaseio.com',
    storageBucket: 'shraddha-ab5ad.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCeZnAoMaVspjFl5Q5E1aBuckeGxdwKLN8',
    appId: '1:902999392028:ios:bde5001f78824a9f3c44d9',
    messagingSenderId: '902999392028',
    projectId: 'shraddha-ab5ad',
    databaseURL: 'https://shraddha-ab5ad-default-rtdb.firebaseio.com',
    storageBucket: 'shraddha-ab5ad.firebasestorage.app',
    iosBundleId: 'com.example.shraddha',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCeZnAoMaVspjFl5Q5E1aBuckeGxdwKLN8',
    appId: '1:902999392028:ios:bde5001f78824a9f3c44d9',
    messagingSenderId: '902999392028',
    projectId: 'shraddha-ab5ad',
    databaseURL: 'https://shraddha-ab5ad-default-rtdb.firebaseio.com',
    storageBucket: 'shraddha-ab5ad.firebasestorage.app',
    iosBundleId: 'com.example.shraddha',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBL1z2ojDG47JOzHwlS9v4V35UvlLbkvOE',
    appId: '1:902999392028:web:43417954376332293c44d9',
    messagingSenderId: '902999392028',
    projectId: 'shraddha-ab5ad',
    authDomain: 'shraddha-ab5ad.firebaseapp.com',
    databaseURL: 'https://shraddha-ab5ad-default-rtdb.firebaseio.com',
    storageBucket: 'shraddha-ab5ad.firebasestorage.app',
    measurementId: 'G-B1DKDH803G',
  );
}

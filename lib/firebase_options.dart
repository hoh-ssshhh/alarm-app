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
    apiKey: 'AIzaSyCzrJ0kTyl3Nzih7N5fFUlObL4o3kURE4c',
    appId: '1:406306735772:web:fb723630c5a3992d840f59',
    messagingSenderId: '406306735772',
    projectId: 'sharealarm-hoo',
    authDomain: 'sharealarm-hoo.firebaseapp.com',
    storageBucket: 'sharealarm-hoo.firebasestorage.app',
    measurementId: 'G-YK0YTTSKQ0',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDHTONtYkNBYOtQtwSZxUYMBE0KSHO8_gI',
    appId: '1:406306735772:android:662996b19299c45c840f59',
    messagingSenderId: '406306735772',
    projectId: 'sharealarm-hoo',
    storageBucket: 'sharealarm-hoo.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAeV0cFg_HXaNohquzJFuNqMpVa8KmkjFA',
    appId: '1:406306735772:ios:a6b9fc47c8cb08d8840f59',
    messagingSenderId: '406306735772',
    projectId: 'sharealarm-hoo',
    storageBucket: 'sharealarm-hoo.firebasestorage.app',
    iosClientId: '406306735772-0tn1pd4d1o16i0am76m3ve6ok1n2gqqf.apps.googleusercontent.com',
    iosBundleId: 'com.example.alarm',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAeV0cFg_HXaNohquzJFuNqMpVa8KmkjFA',
    appId: '1:406306735772:ios:a6b9fc47c8cb08d8840f59',
    messagingSenderId: '406306735772',
    projectId: 'sharealarm-hoo',
    storageBucket: 'sharealarm-hoo.firebasestorage.app',
    iosClientId: '406306735772-0tn1pd4d1o16i0am76m3ve6ok1n2gqqf.apps.googleusercontent.com',
    iosBundleId: 'com.example.alarm',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCzrJ0kTyl3Nzih7N5fFUlObL4o3kURE4c',
    appId: '1:406306735772:web:6aef9e13c48d3e88840f59',
    messagingSenderId: '406306735772',
    projectId: 'sharealarm-hoo',
    authDomain: 'sharealarm-hoo.firebaseapp.com',
    storageBucket: 'sharealarm-hoo.firebasestorage.app',
    measurementId: 'G-88LK6WE6HW',
  );
}

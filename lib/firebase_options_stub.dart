// Firebase configuration for SOVA app
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web platform not configured');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('Platform not configured');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDsRM-d3bdFRJ0hpiAG6YxMt6-MziQ01OU',
    appId: '1:800006114552:android:9d45cca89b514563e3ff0d',
    messagingSenderId: '800006114552',
    projectId: 'sova-166a6',
    storageBucket: 'sova-166a6.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDsRM-d3bdFRJ0hpiAG6YxMt6-MziQ01OU',
    appId: '1:800006114552:ios:9d45cca89b514563e3ff0d',
    messagingSenderId: '800006114552',
    projectId: 'sova-166a6',
    storageBucket: 'sova-166a6.firebasestorage.app',
    iosBundleId: 'com.example.sova',
  );
}

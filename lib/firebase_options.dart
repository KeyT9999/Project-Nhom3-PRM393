import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

/// Cấu hình Firebase tự động trích xuất từ `android/app/google-services.json`
/// Project ID: project-prm393-dc768
/// Package Name: com.prm393.smartstore
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD8lzzoAcR5QLwc2YlNiwi2jY5lXblIiEk',
    appId: '1:8251934788:android:1d681e474c2111e0841411',
    messagingSenderId: '8251934788',
    projectId: 'project-prm393-dc768',
    storageBucket: 'project-prm393-dc768.firebasestorage.app',
  );
}

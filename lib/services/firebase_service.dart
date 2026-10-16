import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../firebase_options.dart';

/// Central Firebase initialization manager.
/// Safely initializes Firebase using the generated DefaultFirebaseOptions.
class FirebaseService {
  static bool _isInitialized = false;
  static String? _initializationError;

  static bool get isInitialized => _isInitialized;
  static String? get initializationError => _initializationError;

  static Future<void> initialize() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        _isInitialized = true;
        return;
      }

      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } catch (_) {
        // Fallback if running on desktop or without currentPlatform options
        await Firebase.initializeApp();
      }

      _isInitialized = true;
      debugPrint('[FirebaseService] Successfully initialized Firebase with real options');
    } catch (e) {
      _isInitialized = false;
      _initializationError = e.toString();
      debugPrint('[FirebaseService] Firebase init fallback: $e');
    }
  }
}

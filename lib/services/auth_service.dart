import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import 'firebase_service.dart';
import 'firestore_service.dart';

class AuthService {
  final FirebaseAuth? _auth;
  final FirestoreService _firestoreService;

  AuthService({
    FirebaseAuth? auth,
    FirestoreService? firestoreService,
  })  : _auth = auth ?? (FirebaseService.isInitialized ? FirebaseAuth.instance : null),
        _firestoreService = firestoreService ?? FirestoreService();

  User? get currentUser => _auth?.currentUser;

  Stream<User?> get authStateChanges {
    if (_auth == null) {
      return Stream.value(null);
    }
    return _auth.authStateChanges();
  }

  /// Registers a new student with Email & Password and creates their profile in Firestore.
  Future<UserProfile> register({
    required String email,
    required String password,
    required String fullName,
    required String college,
    required String department,
    required String year,
  }) async {
    if (_auth == null) {
      throw Exception('Firebase is not configured. Please connect Firebase to register.');
    }

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('User creation failed: null user credential received.');
      }

      await user.updateDisplayName(fullName.trim());

      final initialProfile = UserProfile(
        id: user.uid,
        fullName: fullName.trim(),
        email: email.trim(),
        college: college.trim(),
        department: department.trim(),
        year: year.trim(),
        bio: 'Hey there! I am learning and teaching on SkillLoop.',
        photoUrl: 'https://i.pravatar.cc/150?u=${user.uid}',
        skillsToTeach: const ['General Study'],
        skillsToLearn: const ['Flutter', 'Design'],
        isAvailable: true,
        averageRating: 5.0,
        reviewCount: 0,
        completedExchanges: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestoreService.createUserProfile(initialProfile);
      return initialProfile;
    } on FirebaseAuthException catch (e) {
      debugPrint('[AuthService] FirebaseAuthException during register: ${e.code}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('[AuthService] Exception during register: $e');
      rethrow;
    }
  }

  /// Signs in an existing student.
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    if (_auth == null) {
      throw Exception('Firebase is not configured. Please connect Firebase to sign in.');
    }

    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sends a password reset email.
  Future<void> sendPasswordResetEmail(String email) async {
    if (_auth == null) {
      throw Exception('Firebase is not configured. Please connect Firebase to reset password.');
    }

    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    if (_auth != null) {
      await _auth.signOut();
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect password or invalid credentials.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'weak-password':
        return 'The password is too weak. Must be at least 6 characters.';
      case 'network-request-failed':
        return 'Network connection error. Please check your internet.';
      default:
        return e.message ?? 'Authentication error occurred.';
    }
  }
}

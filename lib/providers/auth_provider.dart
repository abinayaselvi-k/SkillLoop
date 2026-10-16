import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final FirestoreService _firestoreService;

  User? _firebaseUser;
  UserProfile? _currentProfile;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<UserProfile?>? _profileSub;

  // Fallback demo profile matching the initial wireframe greeting ("Hi, Abinaya! 👋")
  static final UserProfile demoCurrentUser = UserProfile(
    id: 'abinaya_current_user',
    fullName: 'Abinaya',
    email: 'abinaya@skillloop.edu',
    college: 'PSG College of Technology',
    department: 'CSE',
    year: '3rd Year',
    bio: 'Looking to learn UI/UX Design and Python data analysis. Happy to teach Flutter and Java!',
    photoUrl: 'https://i.pravatar.cc/150?img=49',
    skillsToTeach: ['Flutter', 'Java', 'Data Structures'],
    skillsToLearn: ['UI/UX Design', 'Python', 'Figma'],
    isAvailable: true,
    averageRating: 4.9,
    reviewCount: 12,
    completedExchanges: 7,
    isDemo: false,
    createdAt: DateTime.now(),
  );

  AuthProvider({
    AuthService? authService,
    FirestoreService? firestoreService,
  })  : _authService = authService ?? AuthService(),
        _firestoreService = firestoreService ?? FirestoreService() {
    _initAuthListener();
  }

  User? get firebaseUser => _firebaseUser;
  UserProfile get currentProfile => _currentProfile ?? demoCurrentUser;
  bool get isAuthenticated => _firebaseUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _initAuthListener() {
    _authService.authStateChanges.listen((user) {
      _firebaseUser = user;
      if (user != null) {
        _listenToProfile(user.uid);
      } else {
        _profileSub?.cancel();
        _currentProfile = null;
        notifyListeners();
      }
    });
  }

  void _listenToProfile(String uid) {
    _profileSub?.cancel();
    _profileSub = _firestoreService.streamUserProfile(uid).listen((profile) {
      if (profile != null) {
        _currentProfile = profile;
        notifyListeners();
      }
    });
  }

  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    required String college,
    required String department,
    required String year,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final profile = await _authService.register(
        email: email,
        password: password,
        fullName: fullName,
        college: college,
        department: department,
        year: year,
      );
      _currentProfile = profile;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final cred = await _authService.signIn(email: email, password: password);
      if (cred.user != null) {
        final profile = await _firestoreService.getUserProfile(cred.user!.uid);
        if (profile != null) {
          _currentProfile = profile;
        }
      }
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> sendPasswordReset(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.sendPasswordResetEmail(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  Future<void> updateProfile(UserProfile updated) async {
    _setLoading(true);
    try {
      if (_firebaseUser != null) {
        await _firestoreService.updateUserProfile(updated);
      }
      _currentProfile = updated;
      _setLoading(false);
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _currentProfile = null;
    notifyListeners();
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  @override
  void dispose() {
    _profileSub?.cancel();
    super.dispose();
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/firestore_service.dart';
import '../services/sample_data_service.dart';

class ExploreProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;

  List<UserProfile> _allStudents = [];
  String _searchQuery = '';
  int _selectedCategoryIndex = -1;
  String? _selectedDepartment;
  bool _isLoading = false;
  StreamSubscription<List<UserProfile>>? _studentsSub;
  String? _userId;

  static const List<String> categories = [
    '💻  Technology',
    '🎨  Design',
    '📸  Creative',
    '🗣  Communication',
    '📚  Academics',
  ];

  static const Map<String, List<String>> categoryKeywords = {
    'Technology': [
      'coding',
      'python',
      'flutter',
      'dart',
      'java',
      'c++',
      'sql',
      'web',
      'data',
      'tech',
    ],
    'Design': [
      'ui/ux',
      'design',
      'figma',
      'canva',
      'photoshop',
      'illustrator',
      'wireframing',
      'cad',
      'solidworks',
    ],
    'Creative': [
      'photo',
      'video',
      'editing',
      'creative',
      'art',
      'music',
      'content',
      '3d',
    ],
    'Communication': [
      'communication',
      'public speaking',
      'interview',
      'english',
      'resume',
      'presentation',
      'writing',
    ],
    'Academics': [
      'math',
      'physics',
      'chemistry',
      'calculus',
      'engineering',
      'study',
      'general',
      'management',
    ],
  };

  ExploreProvider({FirestoreService? firestoreService})
    : _firestoreService = firestoreService ?? FirestoreService();

  List<UserProfile> get allStudents =>
      _allStudents.isNotEmpty ? _allStudents : SampleDataService.demoStudents;

  String get searchQuery => _searchQuery;
  int get selectedCategoryIndex => _selectedCategoryIndex;
  String? get selectedDepartment => _selectedDepartment;
  bool get isLoading => _isLoading;

  /// Starts a Firestore listener only after authentication is available.
  ///
  /// Firestore rules intentionally reject the full student-directory query for
  /// signed-out users. Retrying here when the auth session changes prevents the
  /// app from remaining on its local demo fallback after a successful login.
  void updateUserId(String? userId) {
    if (_userId == userId) return;

    _userId = userId;
    _studentsSub?.cancel();
    _studentsSub = null;

    if (userId == null) {
      _allStudents = SampleDataService.demoStudents;
      _isLoading = false;
      notifyListeners();
      return;
    }

    _initStudentsStream();
  }

  void _initStudentsStream() {
    _isLoading = true;
    _studentsSub = _firestoreService.streamAllStudents().listen(
      (students) {
        if (students.isNotEmpty) {
          _allStudents = students;
        } else {
          // Fallback to demo profiles if no documents in database yet
          _allStudents = SampleDataService.demoStudents;
        }
        _isLoading = false;
        notifyListeners();
      },
      onError: (err) {
        _allStudents = SampleDataService.demoStudents;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(int index) {
    _selectedCategoryIndex = index;
    notifyListeners();
  }

  void setDepartment(String? dept) {
    _selectedDepartment = dept;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategoryIndex = -1;
    _selectedDepartment = null;
    notifyListeners();
  }

  /// Filtered students for Explore screen
  List<UserProfile> get filteredStudents {
    final baseList = allStudents;
    final cleanCategoryName = _selectedCategoryIndex >= 0
        ? categories[_selectedCategoryIndex]
              .replaceAll(RegExp(r'[^\w\s]'), '')
              .trim()
        : null;

    return baseList.where((student) {
      // 1. Search Query Filter
      if (_searchQuery.trim().isNotEmpty) {
        final query = _searchQuery.trim().toLowerCase();
        final matchesName = student.fullName.toLowerCase().contains(query);
        final matchesDept = student.department.toLowerCase().contains(query);
        final matchesCollege = student.college.toLowerCase().contains(query);
        final matchesSkills = student.skillsToTeach.any(
          (s) => s.toLowerCase().contains(query),
        );
        final matchesLearn = student.skillsToLearn.any(
          (s) => s.toLowerCase().contains(query),
        );

        if (!matchesName &&
            !matchesDept &&
            !matchesCollege &&
            !matchesSkills &&
            !matchesLearn) {
          return false;
        }
      }

      // 2. Category Filter (match keywords to teaching skills)
      final keywords = cleanCategoryName == null
          ? const <String>[]
          : categoryKeywords[cleanCategoryName] ?? const <String>[];
      if (keywords.isNotEmpty) {
        final matchesCategory = student.skillsToTeach.any((skill) {
          final sLower = skill.toLowerCase();
          return keywords.any((k) => sLower.contains(k));
        });
        if (!matchesCategory) {
          return false;
        }
      }

      // 3. Department Filter
      if (_selectedDepartment != null && _selectedDepartment!.isNotEmpty) {
        if (!student.department.toLowerCase().contains(
          _selectedDepartment!.toLowerCase(),
        )) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  /// Recommended students for Homepage
  List<UserProfile> get recommendedStudents {
    final list = List<UserProfile>.from(allStudents);
    // Sort by rating and completed exchanges
    list.sort((a, b) => b.averageRating.compareTo(a.averageRating));
    return list.take(6).toList();
  }

  @override
  void dispose() {
    _studentsSub?.cancel();
    super.dispose();
  }
}

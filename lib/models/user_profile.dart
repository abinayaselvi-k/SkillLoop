import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  // Fallbacks for demo documents seeded before `teachingSkillDescriptions`
  // existed. These are display-only: real profiles never receive defaults and
  // no existing Firestore document is rewritten.
  static const Map<String, String> _legacyDemoDescriptions = {
    'UI/UX Design':
        'Learn user-centred interface design, wireframes, and accessible layouts.',
    'Figma':
        'Create wireframes, prototypes, components, and collaborative design files.',
    'Canva': 'Design clear posters, presentations, and social-media graphics.',
    'Prototyping':
        'Turn ideas into interactive flows for testing and feedback.',
    'Python':
        'Learn Python fundamentals, automation, and practical problem solving.',
    'Data Analysis':
        'Clean, explore, and explain data using beginner-friendly workflows.',
    'SQL': 'Write queries to retrieve, filter, and summarize database data.',
    'NumPy': 'Work with arrays and numerical operations in Python.',
    'Flutter':
        'Build responsive mobile interfaces with widgets, layouts, and navigation.',
    'Dart':
        'Learn Dart syntax, null safety, collections, and asynchronous programming.',
    'Firebase': 'Connect Flutter apps to authentication and Cloud Firestore.',
    'State Management':
        'Organize changing app state with simple, maintainable patterns.',
    'AutoCAD': 'Create accurate 2D technical drawings and engineering layouts.',
    'SolidWorks': 'Model mechanical parts and assemblies in 3D.',
    '3D Printing': 'Prepare models and understand practical print settings.',
    'CAD Design': 'Turn a design idea into clear, manufacturable CAD work.',
    'Public Speaking':
        'Practice confident speaking, structure, and delivery for an audience.',
    'Interview Prep':
        'Prepare answers, confidence, and practical interview techniques.',
    'Resume Writing':
        'Create a focused student resume that presents your strengths clearly.',
    'Communication':
        'Improve everyday professional and team communication skills.',
  };

  final String id;
  final String fullName;
  final String email;
  final String college;
  final String department;
  final String year;
  final String bio;
  final String photoUrl;
  final List<String> skillsToTeach;
  final List<String> skillsToLearn;

  /// Descriptions keyed by the exact teaching-skill name.
  ///
  /// The original app stores skills as string lists. Keeping those lists avoids
  /// a destructive migration and preserves matching, searching, and requests.
  final Map<String, String> teachingSkillDescriptions;
  final bool isAvailable;
  final double averageRating;
  final int reviewCount;
  final int completedExchanges;
  final bool isDemo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.college,
    required this.department,
    required this.year,
    this.bio = '',
    this.photoUrl = '',
    this.skillsToTeach = const [],
    this.skillsToLearn = const [],
    this.teachingSkillDescriptions = const {},
    this.isAvailable = true,
    this.averageRating = 5.0,
    this.reviewCount = 0,
    this.completedExchanges = 0,
    this.isDemo = false,
    this.createdAt,
    this.updatedAt,
  });

  String get courseInfo => '$department • $year';

  String get primaryTeachingSkill =>
      skillsToTeach.isNotEmpty ? skillsToTeach.first : 'General Skills';

  String? teachingSkillDescription(String skill) {
    final description = teachingSkillDescriptions[skill]?.trim();
    return description == null || description.isEmpty ? null : description;
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'college': college,
      'department': department,
      'year': year,
      'bio': bio,
      'photoUrl': photoUrl,
      'skillsToTeach': skillsToTeach,
      'skillsToLearn': skillsToLearn,
      'teachingSkillDescriptions': teachingSkillDescriptions,
      'isAvailable': isAvailable,
      'averageRating': averageRating,
      'reviewCount': reviewCount,
      'completedExchanges': completedExchanges,
      'isDemo': isDemo,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory UserProfile.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return UserProfile.fromMap(data, doc.id);
  }

  factory UserProfile.fromMap(Map<String, dynamic> map, String id) {
    DateTime? parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    final teachingSkills = List<String>.from(map['skillsToTeach'] ?? const []);
    final rawDescriptions = map['teachingSkillDescriptions'];
    final descriptions = <String, String>{};
    if (rawDescriptions is Map) {
      rawDescriptions.forEach((key, value) {
        if (key is String && value is String && value.trim().isNotEmpty) {
          descriptions[key] = value.trim();
        }
      });
    }
    final isDemo = map['isDemo'] as bool? ?? false;
    if (isDemo && descriptions.isEmpty) {
      for (final skill in teachingSkills) {
        final fallback = _legacyDemoDescriptions[skill];
        if (fallback != null) descriptions[skill] = fallback;
      }
    }

    return UserProfile(
      id: id,
      fullName: map['fullName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      college: map['college'] as String? ?? '',
      department: map['department'] as String? ?? '',
      year: map['year'] as String? ?? '',
      bio: map['bio'] as String? ?? '',
      photoUrl: map['photoUrl'] as String? ?? '',
      skillsToTeach: teachingSkills,
      skillsToLearn: List<String>.from(map['skillsToLearn'] ?? []),
      teachingSkillDescriptions: descriptions,
      isAvailable: map['isAvailable'] as bool? ?? true,
      averageRating: (map['averageRating'] as num?)?.toDouble() ?? 5.0,
      reviewCount: (map['reviewCount'] as num?)?.toInt() ?? 0,
      completedExchanges: (map['completedExchanges'] as num?)?.toInt() ?? 0,
      isDemo: isDemo,
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
    );
  }

  UserProfile copyWith({
    String? fullName,
    String? email,
    String? college,
    String? department,
    String? year,
    String? bio,
    String? photoUrl,
    List<String>? skillsToTeach,
    List<String>? skillsToLearn,
    Map<String, String>? teachingSkillDescriptions,
    bool? isAvailable,
    double? averageRating,
    int? reviewCount,
    int? completedExchanges,
    bool? isDemo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      college: college ?? this.college,
      department: department ?? this.department,
      year: year ?? this.year,
      bio: bio ?? this.bio,
      photoUrl: photoUrl ?? this.photoUrl,
      skillsToTeach: skillsToTeach ?? this.skillsToTeach,
      skillsToLearn: skillsToLearn ?? this.skillsToLearn,
      teachingSkillDescriptions:
          teachingSkillDescriptions ?? this.teachingSkillDescriptions,
      isAvailable: isAvailable ?? this.isAvailable,
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
      completedExchanges: completedExchanges ?? this.completedExchanges,
      isDemo: isDemo ?? this.isDemo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

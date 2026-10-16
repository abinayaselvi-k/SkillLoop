import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import 'firebase_service.dart';

class SampleDataService {
  static final List<UserProfile> demoStudents = [
    UserProfile(
      id: 'demo_priya_s',
      fullName: 'Priya S.',
      email: 'priya.demo@skillloop.edu',
      college: 'National Institute of Technology',
      department: 'CSE',
      year: '3rd Year',
      bio:
          'UI/UX enthusiast passionate about creating clean, accessible mobile and web interfaces. Experienced in Figma, user testing, and interactive prototyping.',
      photoUrl: 'https://i.pravatar.cc/300?img=45',
      skillsToTeach: ['UI/UX Design', 'Figma', 'Canva', 'Prototyping'],
      teachingSkillDescriptions: {
        'UI/UX Design':
            'Learn user-centred interface design, wireframes, and accessible layouts.',
        'Figma':
            'Create wireframes, prototypes, components, and collaborative design files.',
        'Canva':
            'Design clear posters, presentations, and social-media graphics.',
        'Prototyping':
            'Turn ideas into interactive flows for testing and feedback.',
      },
      skillsToLearn: ['Python', 'Data Analysis', 'SQL'],
      isAvailable: true,
      averageRating: 4.8,
      reviewCount: 14,
      completedExchanges: 8,
      isDemo: true,
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
    ),
    UserProfile(
      id: 'demo_rahul_k',
      fullName: 'Rahul K.',
      email: 'rahul.demo@skillloop.edu',
      college: 'College of Engineering',
      department: 'ECE',
      year: '2nd Year',
      bio:
          'Python developer fascinated by automation, data analytics, and embedded systems. Eager to learn modern design tools to build pretty apps.',
      photoUrl: 'https://i.pravatar.cc/300?img=12',
      skillsToTeach: ['Python', 'Data Analysis', 'SQL', 'NumPy'],
      teachingSkillDescriptions: {
        'Python':
            'Learn Python fundamentals, automation, and practical problem solving.',
        'Data Analysis':
            'Clean, explore, and explain data using beginner-friendly workflows.',
        'SQL':
            'Write queries to retrieve, filter, and summarize database data.',
        'NumPy': 'Work with arrays and numerical operations in Python.',
      },
      skillsToLearn: ['UI/UX Design', 'Figma', 'Wireframing'],
      isAvailable: true,
      averageRating: 4.7,
      reviewCount: 9,
      completedExchanges: 6,
      isDemo: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    UserProfile(
      id: 'demo_ananya_m',
      fullName: 'Ananya M.',
      email: 'ananya.demo@skillloop.edu',
      college: 'Institute of Science & Technology',
      department: 'IT',
      year: '4th Year',
      bio:
          'Cross-platform app developer working with Flutter & Firebase. Love breaking down complex mobile architecture into simple concepts.',
      photoUrl: 'https://i.pravatar.cc/300?img=32',
      skillsToTeach: ['Flutter', 'Dart', 'Firebase', 'State Management'],
      teachingSkillDescriptions: {
        'Flutter':
            'Build responsive mobile interfaces with widgets, layouts, and navigation.',
        'Dart':
            'Learn Dart syntax, null safety, collections, and asynchronous programming.',
        'Firebase':
            'Connect Flutter apps to authentication and Cloud Firestore.',
        'State Management':
            'Organize changing app state with simple, maintainable patterns.',
      },
      skillsToLearn: ['Machine Learning', 'Public Speaking', 'System Design'],
      isAvailable: true,
      averageRating: 4.9,
      reviewCount: 22,
      completedExchanges: 15,
      isDemo: true,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
    UserProfile(
      id: 'demo_vikram_p',
      fullName: 'Vikram P.',
      email: 'vikram.demo@skillloop.edu',
      college: 'Apex Engineering College',
      department: 'Mech',
      year: '3rd Year',
      bio:
          'Mechanical engineering student with expertise in 3D CAD modeling and digital manufacturing. Looking to pick up C++ and embedded coding.',
      photoUrl: 'https://i.pravatar.cc/300?img=56',
      skillsToTeach: ['AutoCAD', 'SolidWorks', '3D Printing', 'CAD Design'],
      teachingSkillDescriptions: {
        'AutoCAD':
            'Create accurate 2D technical drawings and engineering layouts.',
        'SolidWorks': 'Model mechanical parts and assemblies in 3D.',
        '3D Printing':
            'Prepare models and understand practical print settings.',
        'CAD Design': 'Turn a design idea into clear, manufacturable CAD work.',
      },
      skillsToLearn: ['C++', 'Robotics', 'Arduino'],
      isAvailable: true,
      averageRating: 4.6,
      reviewCount: 7,
      completedExchanges: 4,
      isDemo: true,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
    UserProfile(
      id: 'demo_sneha_t',
      fullName: 'Sneha T.',
      email: 'sneha.demo@skillloop.edu',
      college: 'School of Management',
      department: 'Management',
      year: '1st Year',
      bio:
          'Passionate about communication, campus placements, and soft skills training. Can help with interview prep and resume polishing.',
      photoUrl: 'https://i.pravatar.cc/300?img=25',
      skillsToTeach: [
        'Public Speaking',
        'Interview Prep',
        'Resume Writing',
        'Communication',
      ],
      teachingSkillDescriptions: {
        'Public Speaking':
            'Practice confident speaking, structure, and delivery for an audience.',
        'Interview Prep':
            'Prepare answers, confidence, and practical interview techniques.',
        'Resume Writing':
            'Create a focused student resume that presents your strengths clearly.',
        'Communication':
            'Improve everyday professional and team communication skills.',
      },
      skillsToLearn: ['Excel', 'PowerBI', 'Data Visualization'],
      isAvailable: true,
      averageRating: 4.9,
      reviewCount: 18,
      completedExchanges: 11,
      isDemo: true,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
  ];

  /// Seeds demo profiles into Firestore safely without overwriting or duplicating.
  static Future<int> seedDemoProfiles() async {
    if (!FirebaseService.isInitialized) {
      throw StateError(
        'Firebase is not initialized. Check the Android Firebase configuration and restart the app.',
      );
    }

    if (FirebaseAuth.instance.currentUser == null) {
      throw StateError('Sign in with a real account before seeding demo data.');
    }

    try {
      final collection = FirebaseFirestore.instance.collection('users');
      int count = 0;

      for (final student in demoStudents) {
        final doc = await collection.doc(student.id).get();
        if (!doc.exists) {
          await collection.doc(student.id).set(student.toMap());
          count++;
        }
      }
      debugPrint(
        '[SampleDataService] Seeded $count demo student profiles into Firestore.',
      );
      return count;
    } on FirebaseException catch (e) {
      debugPrint('[SampleDataService] Error seeding demo profiles: $e');
      throw StateError(_firebaseErrorMessage(e));
    }
  }

  /// Removes demo profiles from Firestore if the user wants a clean database.
  static Future<int> clearDemoProfiles() async {
    if (!FirebaseService.isInitialized) {
      throw StateError('Firebase is not initialized.');
    }

    if (FirebaseAuth.instance.currentUser == null) {
      throw StateError(
        'Sign in with a real account before clearing demo data.',
      );
    }

    try {
      final collection = FirebaseFirestore.instance.collection('users');
      final query = await collection.where('isDemo', isEqualTo: true).get();
      int count = 0;

      for (final doc in query.docs) {
        await doc.reference.delete();
        count++;
      }
      return count;
    } on FirebaseException catch (e) {
      debugPrint('[SampleDataService] Error clearing demo profiles: $e');
      throw StateError(_firebaseErrorMessage(e));
    }
  }

  static String _firebaseErrorMessage(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return 'Firestore denied this action. Deploy the project firestore.rules, then try again.';
      case 'failed-precondition':
        return 'Cloud Firestore has not been created yet. Create it in Firebase Console, then try again.';
      case 'unavailable':
        return 'Firestore is currently unavailable. Check the phone network and try again.';
      default:
        return 'Firestore error (${error.code}): ${error.message ?? 'unknown error'}';
    }
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:skill_loop/models/user_profile.dart';
import 'package:skill_loop/services/matching_service.dart';

void main() {
  group('MatchingService Tests', () {
    final userA = UserProfile(
      id: 'user_a',
      fullName: 'Alice',
      email: 'alice@test.edu',
      college: 'Tech College',
      department: 'CSE',
      year: '3rd Year',
      skillsToTeach: ['Flutter', 'Dart'],
      skillsToLearn: ['UI/UX Design', 'Figma'],
    );

    final userB = UserProfile(
      id: 'user_b',
      fullName: 'Bob',
      email: 'bob@test.edu',
      college: 'Design School',
      department: 'Design',
      year: '2nd Year',
      skillsToTeach: ['UI/UX Design', 'Figma'],
      skillsToLearn: ['Flutter'],
    );

    final userC = UserProfile(
      id: 'user_c',
      fullName: 'Charlie',
      email: 'charlie@test.edu',
      college: 'Arts College',
      department: 'Music',
      year: '1st Year',
      skillsToTeach: ['Guitar', 'Singing'],
      skillsToLearn: ['Cooking'],
    );

    test('Identifies perfect mutual match between Alice and Bob', () {
      final match = MatchingService.evaluateMatch(
        currentUser: userA,
        candidate: userB,
      );

      expect(match, isNotNull);
      expect(match!.isMutual, isTrue);
      expect(match.theyCanTeachYou.contains('UI/UX Design'), isTrue);
      expect(match.youCanTeachThem.contains('Flutter'), isTrue);
      expect(match.score, greaterThan(2.0));
    });

    test('Returns null when skills do not overlap', () {
      final match = MatchingService.evaluateMatch(
        currentUser: userA,
        candidate: userC,
      );

      expect(match, isNull);
    });

    test('calculateMatches sorts mutual matches first', () {
      final matches = MatchingService.calculateMatches(
        currentUser: userA,
        candidates: [userC, userB],
      );

      expect(matches.length, equals(1));
      expect(matches.first.peer.id, equals('user_b'));
    });
  });
}

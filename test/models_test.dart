import 'package:flutter_test/flutter_test.dart';
import 'package:skill_loop/models/exchange_request.dart';
import 'package:skill_loop/models/user_profile.dart';

void main() {
  group('Model Serialization Tests', () {
    test('UserProfile toMap and fromMap works consistently', () {
      final profile = UserProfile(
        id: 'usr_101',
        fullName: 'Priya S.',
        email: 'priya@test.edu',
        college: 'PSG Tech',
        department: 'CSE',
        year: '3rd Year',
        bio: 'Figma designer',
        photoUrl: 'https://test.com/photo.jpg',
        skillsToTeach: ['UI/UX Design', 'Figma'],
        skillsToLearn: ['Python'],
        isAvailable: true,
        averageRating: 4.8,
        reviewCount: 14,
        completedExchanges: 8,
      );

      final map = profile.toMap();
      expect(map['fullName'], equals('Priya S.'));
      expect(map['department'], equals('CSE'));
      expect(map['skillsToTeach'], equals(['UI/UX Design', 'Figma']));

      final reconstituted = UserProfile.fromMap(map, 'usr_101');
      expect(reconstituted.id, equals('usr_101'));
      expect(reconstituted.fullName, equals(profile.fullName));
      expect(reconstituted.courseInfo, equals('CSE • 3rd Year'));
      expect(reconstituted.primaryTeachingSkill, equals('UI/UX Design'));
    });

    test('ExchangeRequest enum status parsing works correctly', () {
      expect(ExchangeStatus.fromString('pending'), equals(ExchangeStatus.pending));
      expect(ExchangeStatus.fromString('accepted'), equals(ExchangeStatus.accepted));
      expect(ExchangeStatus.fromString('rejected'), equals(ExchangeStatus.rejected));
      expect(ExchangeStatus.fromString('completed'), equals(ExchangeStatus.completed));
      expect(ExchangeStatus.fromString('unknown'), equals(ExchangeStatus.pending));
    });
  });
}

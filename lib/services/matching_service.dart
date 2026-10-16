import '../models/user_profile.dart';

class SkillMatchResult {
  final UserProfile peer;
  final List<String> theyCanTeachYou;
  final List<String> youCanTeachThem;
  final bool isMutual;
  final double score;
  final String explanation;

  const SkillMatchResult({
    required this.peer,
    required this.theyCanTeachYou,
    required this.youCanTeachThem,
    required this.isMutual,
    required this.score,
    required this.explanation,
  });
}

class MatchingService {
  /// Normalizes a skill string for comparison (lowercase, trimmed, removed punctuation).
  static String normalizeSkill(String skill) {
    return skill.trim().toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
  }

  /// Checks if two skills match using normalized exact match or substring containment.
  static bool skillsMatch(String a, String b) {
    final normA = normalizeSkill(a);
    final normB = normalizeSkill(b);
    if (normA.isEmpty || normB.isEmpty) return false;
    return normA == normB || normA.contains(normB) || normB.contains(normA);
  }

  /// Finds matching skill intersections between two lists.
  static List<String> findSkillOverlap(List<String> listA, List<String> listB) {
    final matched = <String>{};
    for (final a in listA) {
      for (final b in listB) {
        if (skillsMatch(a, b)) {
          matched.add(b);
        }
      }
    }
    return matched.toList();
  }

  /// Evaluates a candidate peer against the current user's profile.
  static SkillMatchResult? evaluateMatch({
    required UserProfile currentUser,
    required UserProfile candidate,
  }) {
    if (currentUser.id == candidate.id) return null;

    // What the candidate can teach that the current user wants to learn
    final theyCanTeach = findSkillOverlap(
      currentUser.skillsToLearn,
      candidate.skillsToTeach,
    );

    // What the current user can teach that the candidate wants to learn
    final youCanTeach = findSkillOverlap(
      candidate.skillsToLearn,
      currentUser.skillsToTeach,
    );

    // If candidate can teach at least one skill you want to learn, or it's a mutual exchange
    if (theyCanTeach.isEmpty && youCanTeach.isEmpty) {
      return null;
    }

    final isMutual = theyCanTeach.isNotEmpty && youCanTeach.isNotEmpty;

    // Score: mutual matches get high priority (2.0 + weight of skills), one-way gets 1.0
    double score = 0.0;
    if (isMutual) {
      score = 2.0 + (theyCanTeach.length * 0.5) + (youCanTeach.length * 0.5);
    } else if (theyCanTeach.isNotEmpty) {
      score = 1.0 + (theyCanTeach.length * 0.3);
    } else {
      score = 0.5 + (youCanTeach.length * 0.2);
    }

    String explanation;
    if (isMutual) {
      explanation = '✨ Perfect Mutual Match! ${candidate.fullName} can teach ${theyCanTeach.join(", ")} and wants to learn ${youCanTeach.join(", ")}.';
    } else if (theyCanTeach.isNotEmpty) {
      explanation = '${candidate.fullName} can teach ${theyCanTeach.join(", ")} which you want to learn.';
    } else {
      explanation = '${candidate.fullName} is looking for someone to teach ${youCanTeach.join(", ")}.';
    }

    return SkillMatchResult(
      peer: candidate,
      theyCanTeachYou: theyCanTeach,
      youCanTeachThem: youCanTeach,
      isMutual: isMutual,
      score: score,
      explanation: explanation,
    );
  }

  /// Calculates matches for the current user against a list of candidates, sorted by score.
  static List<SkillMatchResult> calculateMatches({
    required UserProfile currentUser,
    required List<UserProfile> candidates,
  }) {
    final results = <SkillMatchResult>[];

    for (final candidate in candidates) {
      final match = evaluateMatch(
        currentUser: currentUser,
        candidate: candidate,
      );
      if (match != null) {
        results.add(match);
      }
    }

    // Sort highest score first, then by peer averageRating
    results.sort((a, b) {
      final scoreComp = b.score.compareTo(a.score);
      if (scoreComp != 0) return scoreComp;
      return b.peer.averageRating.compareTo(a.peer.averageRating);
    });

    return results;
  }
}

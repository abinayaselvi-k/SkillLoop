import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String exchangeRequestId;
  final String reviewerId;
  final String reviewerName;
  final String reviewerPhotoUrl;
  final String revieweeId;
  final double rating;
  final String comment;
  final DateTime? createdAt;

  const Review({
    required this.id,
    required this.exchangeRequestId,
    required this.reviewerId,
    this.reviewerName = '',
    this.reviewerPhotoUrl = '',
    required this.revieweeId,
    required this.rating,
    this.comment = '',
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'exchangeRequestId': exchangeRequestId,
      'reviewerId': reviewerId,
      'reviewerName': reviewerName,
      'reviewerPhotoUrl': reviewerPhotoUrl,
      'revieweeId': revieweeId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  factory Review.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Review.fromMap(data, doc.id);
  }

  factory Review.fromMap(Map<String, dynamic> map, String id) {
    DateTime? parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    return Review(
      id: id,
      exchangeRequestId: map['exchangeRequestId'] as String? ?? '',
      reviewerId: map['reviewerId'] as String? ?? '',
      reviewerName: map['reviewerName'] as String? ?? '',
      reviewerPhotoUrl: map['reviewerPhotoUrl'] as String? ?? '',
      revieweeId: map['revieweeId'] as String? ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 5.0,
      comment: map['comment'] as String? ?? '',
      createdAt: parseDate(map['createdAt']),
    );
  }
}

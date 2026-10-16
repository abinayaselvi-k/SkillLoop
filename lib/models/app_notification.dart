import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  requestReceived,
  requestAccepted,
  requestRejected,
  newMessage,
  exchangeCompleted,
  reviewReceived;

  static NotificationType fromString(String? val) {
    switch (val) {
      case 'request_accepted':
        return NotificationType.requestAccepted;
      case 'request_rejected':
        return NotificationType.requestRejected;
      case 'new_message':
        return NotificationType.newMessage;
      case 'exchange_completed':
        return NotificationType.exchangeCompleted;
      case 'review_received':
        return NotificationType.reviewReceived;
      case 'request_received':
      default:
        return NotificationType.requestReceived;
    }
  }

  String toDbString() {
    switch (this) {
      case NotificationType.requestReceived:
        return 'request_received';
      case NotificationType.requestAccepted:
        return 'request_accepted';
      case NotificationType.requestRejected:
        return 'request_rejected';
      case NotificationType.newMessage:
        return 'new_message';
      case NotificationType.exchangeCompleted:
        return 'exchange_completed';
      case NotificationType.reviewReceived:
        return 'review_received';
    }
  }
}

class AppNotification {
  final String id;
  final String recipientId;
  final NotificationType type;
  final String title;
  final String body;
  final String relatedId;
  final bool isRead;
  final DateTime? createdAt;

  const AppNotification({
    required this.id,
    required this.recipientId,
    required this.type,
    required this.title,
    required this.body,
    this.relatedId = '',
    this.isRead = false,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'recipientId': recipientId,
      'type': type.toDbString(),
      'title': title,
      'body': body,
      'relatedId': relatedId,
      'isRead': isRead,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  factory AppNotification.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return AppNotification.fromMap(data, doc.id);
  }

  factory AppNotification.fromMap(Map<String, dynamic> map, String id) {
    DateTime? parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    return AppNotification(
      id: id,
      recipientId: map['recipientId'] as String? ?? '',
      type: NotificationType.fromString(map['type'] as String?),
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      relatedId: map['relatedId'] as String? ?? '',
      isRead: map['isRead'] as bool? ?? false,
      createdAt: parseDate(map['createdAt']),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

enum ExchangeStatus {
  pending,
  accepted,
  rejected,
  completed;

  String get label {
    switch (this) {
      case ExchangeStatus.pending:
        return 'Pending';
      case ExchangeStatus.accepted:
        return 'Accepted';
      case ExchangeStatus.rejected:
        return 'Declined';
      case ExchangeStatus.completed:
        return 'Completed';
    }
  }

  static ExchangeStatus fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'accepted':
        return ExchangeStatus.accepted;
      case 'rejected':
      case 'declined':
        return ExchangeStatus.rejected;
      case 'completed':
        return ExchangeStatus.completed;
      case 'pending':
      default:
        return ExchangeStatus.pending;
    }
  }
}

class ExchangeRequest {
  final String id;
  final String senderId;
  final String receiverId;
  final String senderName;
  final String receiverName;
  final String senderPhotoUrl;
  final String receiverPhotoUrl;
  final String offeredSkill;
  final String requestedSkill;
  final String message;
  final ExchangeStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ExchangeRequest({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.senderName = '',
    this.receiverName = '',
    this.senderPhotoUrl = '',
    this.receiverPhotoUrl = '',
    required this.offeredSkill,
    required this.requestedSkill,
    this.message = '',
    this.status = ExchangeStatus.pending,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'senderName': senderName,
      'receiverName': receiverName,
      'senderPhotoUrl': senderPhotoUrl,
      'receiverPhotoUrl': receiverPhotoUrl,
      'offeredSkill': offeredSkill,
      'requestedSkill': requestedSkill,
      'message': message,
      'status': status.name,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory ExchangeRequest.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ExchangeRequest.fromMap(data, doc.id);
  }

  factory ExchangeRequest.fromMap(Map<String, dynamic> map, String id) {
    DateTime? parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    return ExchangeRequest(
      id: id,
      senderId: map['senderId'] as String? ?? '',
      receiverId: map['receiverId'] as String? ?? '',
      senderName: map['senderName'] as String? ?? '',
      receiverName: map['receiverName'] as String? ?? '',
      senderPhotoUrl: map['senderPhotoUrl'] as String? ?? '',
      receiverPhotoUrl: map['receiverPhotoUrl'] as String? ?? '',
      offeredSkill: map['offeredSkill'] as String? ?? '',
      requestedSkill: map['requestedSkill'] as String? ?? '',
      message: map['message'] as String? ?? '',
      status: ExchangeStatus.fromString(map['status'] as String?),
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
    );
  }
}

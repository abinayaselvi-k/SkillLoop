import 'package:cloud_firestore/cloud_firestore.dart';

class Conversation {
  final String id;
  final List<String> participantIds;
  final Map<String, String> participantNames;
  final Map<String, String> participantPhotos;
  final String lastMessage;
  final String lastMessageSenderId;
  final DateTime? lastMessageAt;
  final String? relatedRequestId;

  const Conversation({
    required this.id,
    required this.participantIds,
    this.participantNames = const {},
    this.participantPhotos = const {},
    this.lastMessage = '',
    this.lastMessageSenderId = '',
    this.lastMessageAt,
    this.relatedRequestId,
  });

  String getOtherUserId(String currentUserId) {
    return participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
  }

  String getOtherUserName(String currentUserId) {
    final otherId = getOtherUserId(currentUserId);
    return participantNames[otherId] ?? 'Student';
  }

  String getOtherUserPhoto(String currentUserId) {
    final otherId = getOtherUserId(currentUserId);
    return participantPhotos[otherId] ?? '';
  }

  Map<String, dynamic> toMap() {
    return {
      'participantIds': participantIds,
      'participantNames': participantNames,
      'participantPhotos': participantPhotos,
      'lastMessage': lastMessage,
      'lastMessageSenderId': lastMessageSenderId,
      'lastMessageAt': lastMessageAt != null
          ? Timestamp.fromDate(lastMessageAt!)
          : FieldValue.serverTimestamp(),
      'relatedRequestId': relatedRequestId,
    };
  }

  factory Conversation.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Conversation.fromMap(data, doc.id);
  }

  factory Conversation.fromMap(Map<String, dynamic> map, String id) {
    DateTime? parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    return Conversation(
      id: id,
      participantIds: List<String>.from(map['participantIds'] ?? []),
      participantNames: Map<String, String>.from(map['participantNames'] ?? {}),
      participantPhotos: Map<String, String>.from(map['participantPhotos'] ?? {}),
      lastMessage: map['lastMessage'] as String? ?? '',
      lastMessageSenderId: map['lastMessageSenderId'] as String? ?? '',
      lastMessageAt: parseDate(map['lastMessageAt']),
      relatedRequestId: map['relatedRequestId'] as String?,
    );
  }
}

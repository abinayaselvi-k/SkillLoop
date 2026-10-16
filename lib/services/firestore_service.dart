import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_notification.dart';
import '../models/chat_message.dart';
import '../models/conversation.dart';
import '../models/exchange_request.dart';
import '../models/review.dart';
import '../models/user_profile.dart';
import 'firebase_service.dart';

class FirestoreService {
  final FirebaseFirestore? _firestore;

  FirestoreService({FirebaseFirestore? firestore})
    : _firestore =
          firestore ??
          (FirebaseService.isInitialized ? FirebaseFirestore.instance : null);

  bool get isAvailable => _firestore != null;

  // Collection References
  CollectionReference<Map<String, dynamic>>? get _usersRef =>
      _firestore?.collection('users');
  CollectionReference<Map<String, dynamic>>? get _requestsRef =>
      _firestore?.collection('exchangeRequests');
  CollectionReference<Map<String, dynamic>>? get _conversationsRef =>
      _firestore?.collection('conversations');
  CollectionReference<Map<String, dynamic>>? get _reviewsRef =>
      _firestore?.collection('reviews');
  CollectionReference<Map<String, dynamic>>? get _notificationsRef =>
      _firestore?.collection('notifications');

  // ===========================================================================
  // USERS & PROFILES
  // ===========================================================================

  Future<void> createUserProfile(UserProfile profile) async {
    if (_usersRef == null) return;
    await _usersRef!.doc(profile.id).set(profile.toMap());
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    if (_usersRef == null) return;
    await _usersRef!.doc(profile.id).update(profile.toMap());
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    if (_usersRef == null) return null;
    final doc = await _usersRef!.doc(uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromFirestore(doc);
  }

  Stream<UserProfile?> streamUserProfile(String uid) {
    if (_usersRef == null) return Stream.value(null);
    return _usersRef!.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserProfile.fromFirestore(doc);
    });
  }

  Stream<List<UserProfile>> streamAllStudents({String? excludeUserId}) {
    if (_usersRef == null) return Stream.value([]);
    return _usersRef!.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => UserProfile.fromFirestore(doc))
          .where((p) => excludeUserId == null || p.id != excludeUserId)
          .toList();
    });
  }

  // ===========================================================================
  // SKILL EXCHANGE REQUESTS
  // ===========================================================================

  Future<String> sendExchangeRequest(ExchangeRequest request) async {
    if (_requestsRef == null) {
      throw Exception('Firestore not initialized');
    }

    final docRef = _requestsRef!.doc();
    final newRequest = ExchangeRequest(
      id: docRef.id,
      senderId: request.senderId,
      receiverId: request.receiverId,
      senderName: request.senderName,
      receiverName: request.receiverName,
      senderPhotoUrl: request.senderPhotoUrl,
      receiverPhotoUrl: request.receiverPhotoUrl,
      offeredSkill: request.offeredSkill,
      requestedSkill: request.requestedSkill,
      message: request.message,
      status: ExchangeStatus.pending,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await docRef.set(newRequest.toMap());

    // Send in-app notification to receiver
    await createNotification(
      AppNotification(
        id: '',
        recipientId: request.receiverId,
        type: NotificationType.requestReceived,
        title: 'New Skill Exchange Request! 🤝',
        body:
            '${request.senderName} wants to exchange ${request.offeredSkill} for your ${request.requestedSkill}.',
        relatedId: docRef.id,
        createdAt: DateTime.now(),
      ),
    );

    return docRef.id;
  }

  Stream<List<ExchangeRequest>> streamReceivedRequests(String userId) {
    if (_requestsRef == null) return Stream.value([]);
    return _requestsRef!.where('receiverId', isEqualTo: userId).snapshots().map(
      (snapshot) {
        final list = snapshot.docs
            .map((doc) => ExchangeRequest.fromFirestore(doc))
            .toList();
        list.sort(
          (a, b) => (b.createdAt ?? DateTime(2000)).compareTo(
            a.createdAt ?? DateTime(2000),
          ),
        );
        return list;
      },
    );
  }

  Stream<List<ExchangeRequest>> streamSentRequests(String userId) {
    if (_requestsRef == null) return Stream.value([]);
    return _requestsRef!.where('senderId', isEqualTo: userId).snapshots().map((
      snapshot,
    ) {
      final list = snapshot.docs
          .map((doc) => ExchangeRequest.fromFirestore(doc))
          .toList();
      list.sort(
        (a, b) => (b.createdAt ?? DateTime(2000)).compareTo(
          a.createdAt ?? DateTime(2000),
        ),
      );
      return list;
    });
  }

  Future<void> updateRequestStatus(
    String requestId,
    ExchangeStatus status, {
    required String actorId,
    required String senderId,
    required String receiverId,
    required String receiverName,
    required String senderName,
    required String offeredSkill,
    required String requestedSkill,
  }) async {
    if (_requestsRef == null) return;

    await _requestsRef!.doc(requestId).update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Notify appropriate party
    if (status == ExchangeStatus.accepted) {
      await createNotification(
        AppNotification(
          id: '',
          recipientId: senderId,
          type: NotificationType.requestAccepted,
          title: 'Request Accepted! 🎉',
          body: '$receiverName accepted your exchange for $requestedSkill.',
          relatedId: requestId,
          createdAt: DateTime.now(),
        ),
      );
    } else if (status == ExchangeStatus.rejected) {
      await createNotification(
        AppNotification(
          id: '',
          recipientId: senderId,
          type: NotificationType.requestRejected,
          title: 'Request Declined',
          body: '$receiverName is not available for this exchange right now.',
          relatedId: requestId,
          createdAt: DateTime.now(),
        ),
      );
    } else if (status == ExchangeStatus.completed) {
      final otherUserId = actorId == senderId ? receiverId : senderId;
      final otherUserName = actorId == senderId ? receiverName : senderName;

      await createNotification(
        AppNotification(
          id: '',
          recipientId: otherUserId,
          type: NotificationType.exchangeCompleted,
          title: 'Exchange Completed! ⭐',
          body:
              '$otherUserName marked your exchange as completed. Leave a review!',
          relatedId: requestId,
          createdAt: DateTime.now(),
        ),
      );
    }
  }

  // ===========================================================================
  // CONVERSATIONS & 1-ON-1 CHAT
  // ===========================================================================

  Future<String> getOrCreateConversation({
    required String currentUserId,
    required String otherUserId,
    required String currentUserName,
    required String otherUserName,
    required String currentUserPhoto,
    required String otherUserPhoto,
    String? relatedRequestId,
  }) async {
    if (_conversationsRef == null) {
      throw Exception('Firestore not initialized');
    }

    // Check if conversation already exists between these 2 users
    final query = await _conversationsRef!
        .where('participantIds', arrayContains: currentUserId)
        .get();

    for (final doc in query.docs) {
      final participants = List<String>.from(
        doc.data()['participantIds'] ?? [],
      );
      if (participants.contains(otherUserId)) {
        return doc.id;
      }
    }

    // Otherwise create new conversation
    final newDoc = _conversationsRef!.doc();
    final conversation = Conversation(
      id: newDoc.id,
      participantIds: [currentUserId, otherUserId],
      participantNames: {
        currentUserId: currentUserName,
        otherUserId: otherUserName,
      },
      participantPhotos: {
        currentUserId: currentUserPhoto,
        otherUserId: otherUserPhoto,
      },
      lastMessage: 'Started a skill exchange conversation',
      lastMessageSenderId: currentUserId,
      lastMessageAt: DateTime.now(),
      relatedRequestId: relatedRequestId,
    );

    await newDoc.set(conversation.toMap());
    return newDoc.id;
  }

  Stream<List<Conversation>> streamUserConversations(String userId) {
    if (_conversationsRef == null) return Stream.value([]);
    return _conversationsRef!
        .where('participantIds', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => Conversation.fromFirestore(doc))
              .toList();
          list.sort(
            (a, b) => (b.lastMessageAt ?? DateTime(2000)).compareTo(
              a.lastMessageAt ?? DateTime(2000),
            ),
          );
          return list;
        });
  }

  Stream<List<ChatMessage>> streamMessages(String conversationId) {
    if (_conversationsRef == null) return Stream.value([]);
    return _conversationsRef!
        .doc(conversationId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ChatMessage.fromFirestore(doc))
              .toList();
        });
  }

  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String recipientId,
    required String text,
    required String senderName,
  }) async {
    if (_conversationsRef == null) return;

    final batch = _firestore!.batch();

    // Message document
    final msgDoc = _conversationsRef!
        .doc(conversationId)
        .collection('messages')
        .doc();

    final message = ChatMessage(
      id: msgDoc.id,
      senderId: senderId,
      text: text.trim(),
      createdAt: DateTime.now(),
    );

    batch.set(msgDoc, message.toMap());

    // Update conversation summary
    batch.update(_conversationsRef!.doc(conversationId), {
      'lastMessage': text.trim(),
      'lastMessageSenderId': senderId,
      'lastMessageAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();

    // Create notification for recipient
    await createNotification(
      AppNotification(
        id: '',
        recipientId: recipientId,
        type: NotificationType.newMessage,
        title: 'New message from $senderName',
        body: text.trim(),
        relatedId: conversationId,
        createdAt: DateTime.now(),
      ),
    );
  }

  // ===========================================================================
  // REVIEWS & RATINGS
  // ===========================================================================

  Future<void> submitReview(Review review) async {
    if (_reviewsRef == null || _requestsRef == null) {
      throw StateError('Firestore is not initialized.');
    }

    final exchangeDoc = await _requestsRef!.doc(review.exchangeRequestId).get();
    final exchange = exchangeDoc.data();
    if (!exchangeDoc.exists ||
        exchange?['status'] != ExchangeStatus.completed.name) {
      throw StateError(
        'Reviews can only be submitted after an exchange is completed.',
      );
    }

    final senderId = exchange?['senderId'] as String?;
    final receiverId = exchange?['receiverId'] as String?;
    final isParticipant =
        review.reviewerId == senderId || review.reviewerId == receiverId;
    final isReviewingPeer =
        review.revieweeId != review.reviewerId &&
        (review.revieweeId == senderId || review.revieweeId == receiverId);
    if (!isParticipant || !isReviewingPeer) {
      throw StateError(
        'A review must be for the other participant in this exchange.',
      );
    }

    // A deterministic document ID makes one review per reviewer per exchange
    // enforceable in both the client and Firestore security rules.
    final docRef = _reviewsRef!.doc(
      '${review.exchangeRequestId}_${review.reviewerId}',
    );
    if ((await docRef.get()).exists) {
      throw StateError('You have already reviewed this exchange.');
    }

    final reviewData = Review(
      id: docRef.id,
      exchangeRequestId: review.exchangeRequestId,
      reviewerId: review.reviewerId,
      reviewerName: review.reviewerName,
      reviewerPhotoUrl: review.reviewerPhotoUrl,
      revieweeId: review.revieweeId,
      rating: review.rating,
      comment: review.comment,
      createdAt: DateTime.now(),
    );

    await docRef.set(reviewData.toMap());

    // Send notification
    await createNotification(
      AppNotification(
        id: '',
        recipientId: review.revieweeId,
        type: NotificationType.reviewReceived,
        title: 'New Review Received! ⭐',
        body:
            '${review.reviewerName} gave you a ${review.rating.toStringAsFixed(1)}★ rating.',
        relatedId: review.exchangeRequestId,
        createdAt: DateTime.now(),
      ),
    );
  }

  Stream<List<Review>> streamUserReviews(String revieweeId) {
    if (_reviewsRef == null) return Stream.value([]);
    return _reviewsRef!
        .where('revieweeId', isEqualTo: revieweeId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => Review.fromFirestore(doc))
              .toList();
          list.sort(
            (a, b) => (b.createdAt ?? DateTime(2000)).compareTo(
              a.createdAt ?? DateTime(2000),
            ),
          );
          return list;
        });
  }

  // ===========================================================================
  // IN-APP NOTIFICATIONS
  // ===========================================================================

  Future<void> createNotification(AppNotification notification) async {
    if (_notificationsRef == null) return;
    final docRef = _notificationsRef!.doc();
    final newNotif = AppNotification(
      id: docRef.id,
      recipientId: notification.recipientId,
      type: notification.type,
      title: notification.title,
      body: notification.body,
      relatedId: notification.relatedId,
      isRead: false,
      createdAt: DateTime.now(),
    );
    await docRef.set(newNotif.toMap());
  }

  Stream<List<AppNotification>> streamUserNotifications(String userId) {
    if (_notificationsRef == null) return Stream.value([]);
    return _notificationsRef!
        .where('recipientId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => AppNotification.fromFirestore(doc))
              .toList();
          list.sort(
            (a, b) => (b.createdAt ?? DateTime(2000)).compareTo(
              a.createdAt ?? DateTime(2000),
            ),
          );
          return list;
        });
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    if (_notificationsRef == null) return;
    await _notificationsRef!.doc(notificationId).update({'isRead': true});
  }
}

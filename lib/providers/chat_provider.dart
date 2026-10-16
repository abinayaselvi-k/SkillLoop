import 'dart:async';
import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/conversation.dart';
import '../services/firestore_service.dart';

class ChatProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;

  List<Conversation> _conversations = [];
  StreamSubscription<List<Conversation>>? _conversationsSub;
  String? _currentUserId;

  ChatProvider({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  List<Conversation> get conversations => _conversations;
  int get unreadCount => _conversations
      .where((c) => c.lastMessageSenderId != _currentUserId && c.lastMessage.isNotEmpty)
      .length;

  void updateUserId(String? userId) {
    if (_currentUserId == userId) return;
    _currentUserId = userId;
    _conversationsSub?.cancel();

    if (userId != null && userId.isNotEmpty) {
      _initConversations(userId);
    } else {
      _conversations = [];
      notifyListeners();
    }
  }

  void _initConversations(String userId) {
    _conversationsSub = _firestoreService.streamUserConversations(userId).listen((list) {
      _conversations = list;
      notifyListeners();
    });
  }

  Future<String> startConversation({
    required String currentUserId,
    required String otherUserId,
    required String currentUserName,
    required String otherUserName,
    required String currentUserPhoto,
    required String otherUserPhoto,
    String? relatedRequestId,
  }) async {
    return await _firestoreService.getOrCreateConversation(
      currentUserId: currentUserId,
      otherUserId: otherUserId,
      currentUserName: currentUserName,
      otherUserName: otherUserName,
      currentUserPhoto: currentUserPhoto,
      otherUserPhoto: otherUserPhoto,
      relatedRequestId: relatedRequestId,
    );
  }

  Stream<List<ChatMessage>> streamMessages(String conversationId) {
    return _firestoreService.streamMessages(conversationId);
  }

  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String recipientId,
    required String text,
    required String senderName,
  }) async {
    if (text.trim().isEmpty) return;
    await _firestoreService.sendMessage(
      conversationId: conversationId,
      senderId: senderId,
      recipientId: recipientId,
      text: text,
      senderName: senderName,
    );
  }

  @override
  void dispose() {
    _conversationsSub?.cancel();
    super.dispose();
  }
}

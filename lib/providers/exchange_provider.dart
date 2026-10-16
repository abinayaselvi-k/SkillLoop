import 'dart:async';
import 'package:flutter/material.dart';
import '../models/exchange_request.dart';
import '../services/firestore_service.dart';

class ExchangeProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;

  List<ExchangeRequest> _receivedRequests = [];
  List<ExchangeRequest> _sentRequests = [];
  bool _isLoading = false;
  String? _errorMessage;

  StreamSubscription<List<ExchangeRequest>>? _receivedSub;
  StreamSubscription<List<ExchangeRequest>>? _sentSub;
  String? _currentUserId;

  ExchangeProvider({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  List<ExchangeRequest> get receivedRequests => _receivedRequests;
  List<ExchangeRequest> get sentRequests => _sentRequests;
  int get pendingReceivedCount =>
      _receivedRequests.where((r) => r.status == ExchangeStatus.pending).length;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void updateUserId(String? userId) {
    if (_currentUserId == userId) return;
    _currentUserId = userId;
    _receivedSub?.cancel();
    _sentSub?.cancel();

    if (userId != null && userId.isNotEmpty) {
      _initStreams(userId);
    } else {
      _receivedRequests = [];
      _sentRequests = [];
      notifyListeners();
    }
  }

  void _initStreams(String userId) {
    _receivedSub = _firestoreService.streamReceivedRequests(userId).listen((list) {
      _receivedRequests = list;
      notifyListeners();
    });

    _sentSub = _firestoreService.streamSentRequests(userId).listen((list) {
      _sentRequests = list;
      notifyListeners();
    });
  }

  Future<bool> sendRequest({
    required String senderId,
    required String receiverId,
    required String senderName,
    required String receiverName,
    required String senderPhotoUrl,
    required String receiverPhotoUrl,
    required String offeredSkill,
    required String requestedSkill,
    String message = '',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Check for duplicate pending requests
      final duplicate = _sentRequests.any(
        (r) =>
            r.receiverId == receiverId &&
            r.status == ExchangeStatus.pending &&
            r.offeredSkill.toLowerCase() == offeredSkill.toLowerCase() &&
            r.requestedSkill.toLowerCase() == requestedSkill.toLowerCase(),
      );

      if (duplicate) {
        throw Exception('You already have a pending exchange request with this student for these skills.');
      }

      final request = ExchangeRequest(
        id: '',
        senderId: senderId,
        receiverId: receiverId,
        senderName: senderName,
        receiverName: receiverName,
        senderPhotoUrl: senderPhotoUrl,
        receiverPhotoUrl: receiverPhotoUrl,
        offeredSkill: offeredSkill,
        requestedSkill: requestedSkill,
        message: message,
        status: ExchangeStatus.pending,
      );

      await _firestoreService.sendExchangeRequest(request);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> acceptRequest(ExchangeRequest req) async {
    await _firestoreService.updateRequestStatus(
      req.id,
      ExchangeStatus.accepted,
      actorId: req.receiverId,
      senderId: req.senderId,
      receiverId: req.receiverId,
      receiverName: req.receiverName,
      senderName: req.senderName,
      offeredSkill: req.offeredSkill,
      requestedSkill: req.requestedSkill,
    );
  }

  Future<void> rejectRequest(ExchangeRequest req) async {
    await _firestoreService.updateRequestStatus(
      req.id,
      ExchangeStatus.rejected,
      actorId: req.receiverId,
      senderId: req.senderId,
      receiverId: req.receiverId,
      receiverName: req.receiverName,
      senderName: req.senderName,
      offeredSkill: req.offeredSkill,
      requestedSkill: req.requestedSkill,
    );
  }

  Future<void> completeExchange(ExchangeRequest req, String currentUserId) async {
    await _firestoreService.updateRequestStatus(
      req.id,
      ExchangeStatus.completed,
      actorId: currentUserId,
      senderId: req.senderId,
      receiverId: req.receiverId,
      receiverName: req.receiverName,
      senderName: req.senderName,
      offeredSkill: req.offeredSkill,
      requestedSkill: req.requestedSkill,
    );
  }

  @override
  void dispose() {
    _receivedSub?.cancel();
    _sentSub?.cancel();
    super.dispose();
  }
}

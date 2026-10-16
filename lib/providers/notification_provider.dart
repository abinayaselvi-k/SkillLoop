import 'dart:async';
import 'package:flutter/material.dart';
import '../models/app_notification.dart';
import '../services/firestore_service.dart';

class NotificationProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;

  List<AppNotification> _notifications = [];
  StreamSubscription<List<AppNotification>>? _notifSub;
  String? _currentUserId;

  NotificationProvider({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void updateUserId(String? userId) {
    if (_currentUserId == userId) return;
    _currentUserId = userId;
    _notifSub?.cancel();

    if (userId != null && userId.isNotEmpty) {
      _initNotifications(userId);
    } else {
      _notifications = [];
      notifyListeners();
    }
  }

  void _initNotifications(String userId) {
    _notifSub = _firestoreService.streamUserNotifications(userId).listen((list) {
      _notifications = list;
      notifyListeners();
    });
  }

  Future<void> markAsRead(String id) async {
    await _firestoreService.markNotificationAsRead(id);
  }

  @override
  void dispose() {
    _notifSub?.cancel();
    super.dispose();
  }
}

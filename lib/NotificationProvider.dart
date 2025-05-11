import 'package:flutter/material.dart';

class NotificationModel {
  final String id;
  final IconData icon;
  final String name;
  final String action;
  final String content;
  final String? commentText;
  final String time;
  final bool read;

  NotificationModel({
    required this.id,
    required this.icon,
    required this.name,
    required this.action,
    required this.content,
    this.commentText,
    required this.time,
    required this.read,
  });
}

class NotificationProvider extends ChangeNotifier {
  final Map<String, List<NotificationModel>> _notifications = {

    'room': [],
    'general':[]
  };

  List<NotificationModel> getNotifications(String type) {
    return _notifications[type] ?? [];
  }

  int getUnreadCount(String type) {
    return (_notifications[type] ?? []).where((n) => !n.read).length;
  }

  int get totalUnreadCount {
    int count = 0;
    _notifications.forEach((key, notifications) {
      count += notifications.where((n) => !n.read).length;
    });
    return count;
  }

  void markAsRead(String id) {
    _notifications.forEach((type, notificationsList) {
      final index = notificationsList.indexWhere((n) => n.id == id);
      if (index >= 0) {
        final notification = notificationsList[index];
        notificationsList[index] = NotificationModel(
          id: notification.id,
          icon: notification.icon,
          name: notification.name,
          action: notification.action,
          content: notification.content,
          commentText: notification.commentText,
          time: notification.time,
          read: true,
        );
      }
    });
    notifyListeners();
  }
  void addInitialNotifications(List<dynamic> notifications) {

      for (var notification in notifications) {
        _notifications[notification['type']]!.add(NotificationModel(
          id: notification['id'].toString(),
          icon: _getIconData(notification['icon']??''),
          name: notification['name'],
          action: notification['action'],
          content: notification['content'],
          time: notification['created_at'],
          read: notification['read'],
        ));
      }
      notifyListeners();
  }


// Helper method to match your existing _getIconData from WebSocketService
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'notifications_rounded': return Icons.notifications_rounded;
      case 'alarm_rounded': return Icons.alarm_rounded;
    // Add all your other icon cases here
      default: return Icons.notifications;
    }
  }

  void markAllAsRead(String type) {
    if (_notifications.containsKey(type)) {
      final notificationsList = _notifications[type]!;
      for (int i = 0; i < notificationsList.length; i++) {
        final notification = notificationsList[i];
        notificationsList[i] = NotificationModel(
          id: notification.id,
          icon: notification.icon,
          name: notification.name,
          action: notification.action,
          content: notification.content,
          commentText: notification.commentText,
          time: notification.time,
          read: true,
        );
      }
      notifyListeners();
    }
  }

  void addNotification(NotificationModel notification, String type) {
    if (_notifications.containsKey(type)) {
      _notifications[type]!.insert(0, notification);
      notifyListeners();
    }
  }

  void removeNotification(String id) {
    _notifications.forEach((type, notificationsList) {
      notificationsList.removeWhere((n) => n.id == id);
    });
    notifyListeners();
  }
}
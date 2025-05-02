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
    'general': [
      NotificationModel(
        id: '1',
        icon: Icons.notifications_rounded,
        name: 'Reservation System',
        action: 'Your booking status has changed',
        content: 'Your booking #12345 for Deluxe Room has been confirmed',
        time: '2h ago',
        read: false,
      ),
      NotificationModel(
        id: '2',
        icon: Icons.alarm_rounded,
        name: 'Reservation System',
        action: 'Reminder for your upcoming stay',
        content: 'Your booking starts tomorrow at 3:00 PM. Early check-in available upon request.',
        time: '1d ago',
        read: true,
      ),
      NotificationModel(
        id: '3',
        icon: Icons.payment_rounded,
        name: 'Reservation System',
        action: 'Payment processed',
        content: 'Your payment of \$250.00 for booking #12345 has been processed successfully',
        time: '3d ago',
        read: true,
      ),
      NotificationModel(
        id: '4',
        icon: Icons.local_offer_rounded,
        name: 'Reservation System',
        action: 'Special offer available',
        content: 'Extend your stay and get 15% off for additional nights!',
        time: '5d ago',
        read: true,
      ),
    ],
    'room': [
      NotificationModel(
        id: '5',
        icon: Icons.cleaning_services_rounded,
        name: 'Housekeeping',
        action: 'has updated your room status',
        content: 'Your room #304 has been cleaned and is ready',
        time: '30m ago',
        read: false,
      ),
      NotificationModel(
        id: '6',
        icon: Icons.build_rounded,
        name: 'Maintenance',
        action: 'has completed a repair',
        content: 'The AC in your room #304 has been repaired',
        time: '2h ago',
        read: false,
      ),
      NotificationModel(
        id: '7',
        icon: Icons.room_service_rounded,
        name: 'Room Service',
        action: 'your order is ready',
        content: 'Your breakfast order will be delivered in 10 minutes',
        time: '8:30 AM',
        read: true,
      ),
      NotificationModel(
        id: '8',
        icon: Icons.local_laundry_service,
        name: 'Laundry Service',
        action: 'has completed your request',
        content: 'Your laundry items are ready for pickup',
        time: 'Yesterday',
        read: true,
      ),
      NotificationModel(
        id: '9',
        icon: Icons.do_not_disturb_rounded,
        name: 'Room Status',
        action: 'has been updated',
        content: 'Do Not Disturb sign activated for room #304',
        time: 'Yesterday',
        read: true,
      ),
    ],
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
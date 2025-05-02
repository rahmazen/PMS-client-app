import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'NotificationProvider.dart';

class EnhancedNotificationPage extends StatefulWidget {
  const EnhancedNotificationPage({Key? key}) : super(key: key);

  @override
  _EnhancedNotificationPageState createState() => _EnhancedNotificationPageState();
}

class _EnhancedNotificationPageState extends State<EnhancedNotificationPage> {
  bool isGeneralSelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildToggleBar(),
            Expanded(
              child: isGeneralSelected
                  ? _buildNotificationsList(context, 'general')
                  : _buildNotificationsList(context, 'room'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final totalUnread = notificationProvider.totalUnreadCount;

    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
        Expanded(
        child: Center(
        child: Text(
          "Notifications",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        )
    ),
        ),
    ],
    ),
    );
  }

  Widget _buildToggleBar() {
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final generalUnread = notificationProvider.getUnreadCount('general');
    final roomUnread = notificationProvider.getUnreadCount('room');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isGeneralSelected = true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isGeneralSelected ? Colors.grey[200] : Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications,
                      size: 16,
                      color: isGeneralSelected ? Colors.blueGrey.shade800 : Colors.blueGrey,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "General",
                      style: TextStyle(
                        fontWeight: isGeneralSelected ? FontWeight.bold : FontWeight.normal,
                        color: isGeneralSelected ? Colors.black : Colors.grey,
                      ),
                    ),
                    if (generalUnread > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          generalUnread.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isGeneralSelected = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !isGeneralSelected ? Colors.grey[200] : Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.meeting_room,
                      size: 16,
                      color: !isGeneralSelected ? Colors.black : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Room",
                      style: TextStyle(
                        fontWeight: !isGeneralSelected ? FontWeight.bold : FontWeight.normal,
                        color: !isGeneralSelected ? Colors.black : Colors.grey,
                      ),
                    ),
                    if (roomUnread > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade800,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          roomUnread.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(BuildContext context, String type) {
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final notifications = notificationProvider.getNotifications(type);

    if (notifications.isEmpty) {
      return Center(child: Text("No ${type} notifications"));
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 16.0),
      itemCount: notifications.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding:  EdgeInsets.only( bottom: 7, right: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    notificationProvider.markAllAsRead(type);
                  },
                  child: Text(
                    "Mark all as read",
                    style: TextStyle(
                      color: Colors.blueGrey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final notification = notifications[index - 1];
        return NotificationCard(
          notification: notification,
          isComment: type == 'room',
          onTap: () {
            notificationProvider.markAsRead(notification.id);
          },
        );
      },
    );
  }
}

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final bool isComment;
  final VoidCallback onTap;

  const NotificationCard({
    Key? key,
    required this.notification,
    required this.isComment,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: notification.read ? Colors.white : Colors.blueGrey[50],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: notification.read ? Colors.grey[200] : Colors.blueGrey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  notification.icon,
                  size: 24,
                  color: notification.read ? Colors.grey[600] : Colors.blueGrey[800],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: [
                          TextSpan(
                            text: notification.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: " ${notification.action}",
                            style: const TextStyle(
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.content,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (isComment && notification.commentText != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          notification.commentText!,
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          notification.time,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                        if (!notification.read)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.blueGrey,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
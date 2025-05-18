import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

import '../NotificationProvider.dart';
import '../EnhancedNotificationPage.dart';
import '../ReservationStorage.dart';
import '../SignIn.dart';
import '../api.dart';
import '../providers/authProvider.dart';

class WebSocketService {
  final String? authToken;
  final NotificationProvider notificationProvider;
  final String? reservationId;

  WebSocketChannel? _channel;
  bool _connected = false;
  bool _disposed = false;

  WebSocketService({
    required this.authToken,
    required this.notificationProvider,
    this.reservationId,
  });

  Future<void> connect() async {
    if (_connected || _disposed) return;

    try {
      final wsUrl = reservationId != null && reservationId!.isNotEmpty
          ? '${Api.url}/ws/notifications/${reservationId!}/'
          : '${Api.url}/ws/notifications/default/';

      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _connected = true;

      _channel!.stream.listen(
        _handleMessage,
        onDone: _handleDisconnection,
        onError: (error) => _handleDisconnection(),
      );
    } catch (e) {
      _handleDisconnection();
    }
  }

  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message);
      if (data['message_type'] == 'notification') {
        final notification = data['notification'];
        notificationProvider.addNotification(
          NotificationModel(
            id: notification['id'],
            icon: _getIconData(notification['icon']),
            name: notification['name'],
            action: notification['action'],
            content: notification['content'],
            time: notification['time'],
            read: notification['read'],
          ),
          notification['type'],
        );
      }
    } catch (e) {
      debugPrint('Error handling message: $e');
    }
  }

  void _handleDisconnection() {
    if (!_disposed) {
      _connected = false;
      Future.delayed(const Duration(seconds: 3), connect);
    }
  }

  IconData _getIconData(String iconName) {
    const icons = {
      'notifications_rounded': Icons.notifications_rounded,
      'alarm_rounded': Icons.alarm_rounded,
      'payment_rounded': Icons.payment_rounded,
      'local_offer_rounded': Icons.local_offer_rounded,
      'cleaning_services_rounded': Icons.cleaning_services_rounded,
      'build_rounded': Icons.build_rounded,
      'room_service_rounded': Icons.room_service_rounded,
      'local_laundry_service': Icons.local_laundry_service,
      'do_not_disturb_rounded': Icons.do_not_disturb_rounded,
    };
    return icons[iconName] ?? Icons.notifications;
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final response = await http.post(
        Uri.parse('${Api.url}/backend/guest/notifications/$notificationId/'),
        headers: {
          'Authorization': 'Token $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        notificationProvider.markAsRead(notificationId);
      }
    } catch (e) {
      debugPrint('Error marking as read: $e');
    }
  }

  Future<void> markAllAsRead(String type) async {
    try {
      final response = await http.post(
        Uri.parse('${Api.url}/api/notifications/mark-all-read/'),
        headers: {
          'Authorization': 'Token $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'type': type}),
      );

      if (response.statusCode == 200) {
        notificationProvider.markAllAsRead(type);
      }
    } catch (e) {
      debugPrint('Error marking all as read: $e');
    }
  }

  void dispose() {
    _disposed = true;
    _connected = false;
    _channel?.sink.close();
  }
}

class NotificationsWrapper extends StatefulWidget {
  const NotificationsWrapper({Key? key}) : super(key: key);

  @override
  State<NotificationsWrapper> createState() => _NotificationsWrapperState();
}

class _NotificationsWrapperState extends State<NotificationsWrapper> {
  late final NotificationProvider _notificationProvider;
  WebSocketService? _webSocketService;
  bool _isLoading = true;
  bool _redirecting = false;
  @override
  void initState() {
    super.initState();
    _notificationProvider = context.read<NotificationProvider>();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      // 1. Check authentication
      final auth = context.read<AuthProvider>();
      if (!auth.isAuthenticated) {
        if (mounted && !_redirecting) {
          setState(() => _redirecting = true);
          await Future.delayed(Duration.zero); // Ensure build completes
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => SignInScreen(redirectToPage: NotificationsWrapper(),)),
          );
        }
        return;
      }

      // 2. Load data in parallel 
      final (reservationId, _) = await (
      ReservationStorage.getReservationId(),
      _loadInitialNotifications(auth.authData?.username ?? ''),
      ).wait;

      // 3. Initialize WebSocket
      _webSocketService = WebSocketService(
        authToken: auth.authData?.accessToken,
        notificationProvider: _notificationProvider,
        reservationId: reservationId,
      );
      await _webSocketService?.connect();

      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('Initialization error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load notifications')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  void _redirectToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignInScreen()),
    );
  }

  Future<void> _loadInitialNotifications(String username) async {
    try {
      final response = await http.get(
        Uri.parse('${Api.url}/backend/guest/notifications/$username/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        _notificationProvider.addInitialNotifications(jsonDecode(response.body));
      }
    } catch (e) {
      debugPrint('Notification load error: $e');
    }
  }

  @override
  void dispose() {
    _webSocketService?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Scaffold(body: Center(child: CircularProgressIndicator()))
        : EnhancedNotificationPage(
      webSocketService: _webSocketService!,
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../config/app_theme.dart';
import '../../config/supabase_config.dart';
import '../../services/notification_service.dart';
import '../events/event_details_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  
  final _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    
    try {
      final notifications = await _notificationService.getUserNotifications();
      
      setState(() {
        _notifications = notifications.map((n) => {
          'id': n.id,
          'title': n.title,
          'message': n.message,
          'type': n.type,
          'is_read': n.isRead,
          'event_id': n.eventId,
          'created_at': n.createdAt.toIso8601String(),
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);
      _loadNotifications();
    } catch (e) {
      // Handle error
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'event_reminder':
        return Icons.alarm;
      case 'registration':
        return Icons.confirmation_number;
      case 'cancellation':
        return Icons.cancel;
      case 'update':
        return Icons.update;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (_notifications.any((n) => !n['is_read']))
            TextButton(
              onPressed: () async {
                await _notificationService.markAllAsRead();
                _loadNotifications();
              },
              child: const Text('Mark all as read'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_off,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No notifications',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      final isRead = notification['is_read'];
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: isRead ? null : AppTheme.primaryColor.withOpacity(0.05),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                            child: Icon(
                              _getIconForType(notification['type']),
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          title: Text(
                            notification['title'],
                            style: TextStyle(
                              fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(notification['message']),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('MMM dd, yyyy • hh:mm a').format(
                                  DateTime.parse(notification['created_at']),
                                ),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            if (!isRead) {
                              _markAsRead(notification['id']);
                            }
                            if (notification['related_event_id'] != null) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => EventDetailsScreen(
                                    eventId: notification['related_event_id'],
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

// ================================
// FAVORITES SCREEN
// ================================


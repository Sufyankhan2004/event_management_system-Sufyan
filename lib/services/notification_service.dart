import '../models/notification.dart';
import 'base_service.dart';

// ================================
// NOTIFICATION SERVICE
// ================================
// Handles notification operations

class NotificationService extends BaseService {
  NotificationService() : super('notifications');
  
  // Create a notification
  Future<NotificationModel> createNotification({
    required String userId,
    String? eventId,
    required String title,
    required String message,
    required String type,
  }) async {
    try {
      final notificationData = {
        'user_id': userId,
        'event_id': eventId,
        'title': title,
        'message': message,
        'type': type,
        'is_read': false,
      };
      
      final response = await create(notificationData);
      return NotificationModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create notification: ${e.toString()}');
    }
  }
  
  // Send notification to multiple users
  Future<List<NotificationModel>> sendBulkNotification({
    required List<String> userIds,
    String? eventId,
    required String title,
    required String message,
    required String type,
  }) async {
    try {
      final notifications = <NotificationModel>[];
      
      for (final userId in userIds) {
        final notification = await createNotification(
          userId: userId,
          eventId: eventId,
          title: title,
          message: message,
          type: type,
        );
        notifications.add(notification);
      }
      
      return notifications;
    } catch (e) {
      throw Exception('Failed to send bulk notifications: ${e.toString()}');
    }
  }
  
  // Get user notifications
  Future<List<NotificationModel>> getUserNotifications({String? userId}) async {
    try {
      final targetUserId = userId ?? currentUserId;
      if (targetUserId == null) throw Exception('User not authenticated');
      
      final data = await query(
        filters: {'user_id': targetUserId},
        orderBy: 'created_at',
        ascending: false,
      );
      return data.map((json) => NotificationModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get notifications: ${e.toString()}');
    }
  }
  
  // Get unread notifications
  Future<List<NotificationModel>> getUnreadNotifications({String? userId}) async {
    try {
      final targetUserId = userId ?? currentUserId;
      if (targetUserId == null) throw Exception('User not authenticated');
      
      final response = await client
          .from(tableName)
          .select()
          .eq('user_id', targetUserId)
          .eq('is_read', false)
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response)
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get unread notifications: ${e.toString()}');
    }
  }
  
  // Mark notification as read
  Future<NotificationModel> markAsRead(String notificationId) async {
    try {
      final response = await update(notificationId, {'is_read': true});
      return NotificationModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to mark notification as read: ${e.toString()}');
    }
  }
  
  // Mark all user notifications as read
  Future<void> markAllAsRead({String? userId}) async {
    try {
      final targetUserId = userId ?? currentUserId;
      if (targetUserId == null) throw Exception('User not authenticated');
      
      await client
          .from(tableName)
          .update({'is_read': true})
          .eq('user_id', targetUserId)
          .eq('is_read', false);
    } catch (e) {
      throw Exception('Failed to mark all as read: ${e.toString()}');
    }
  }
  
  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await delete(notificationId);
    } catch (e) {
      throw Exception('Failed to delete notification: ${e.toString()}');
    }
  }
  
  // Get unread count
  Future<int> getUnreadCount({String? userId}) async {
    try {
      final unread = await getUnreadNotifications(userId: userId);
      return unread.length;
    } catch (e) {
      return 0;
    }
  }
  
  // Send event reminder notification
  Future<NotificationModel> sendEventReminder({
    required String userId,
    required String eventId,
    required String eventTitle,
  }) async {
    return await createNotification(
      userId: userId,
      eventId: eventId,
      title: 'Event Reminder',
      message: 'Reminder: $eventTitle is coming up soon!',
      type: 'event_reminder',
    );
  }
  
  // Send registration confirmation notification
  Future<NotificationModel> sendRegistrationConfirmation({
    required String userId,
    required String eventId,
    required String eventTitle,
  }) async {
    return await createNotification(
      userId: userId,
      eventId: eventId,
      title: 'Registration Confirmed',
      message: 'You have successfully registered for $eventTitle',
      type: 'registration',
    );
  }
  
  // Send event update notification
  Future<NotificationModel> sendEventUpdate({
    required String userId,
    required String eventId,
    required String eventTitle,
    required String updateMessage,
  }) async {
    return await createNotification(
      userId: userId,
      eventId: eventId,
      title: 'Event Update',
      message: '$eventTitle: $updateMessage',
      type: 'update',
    );
  }
}

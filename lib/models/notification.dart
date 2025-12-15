// ================================
// NOTIFICATION MODEL
// ================================

class NotificationModel {
  final String id;
  final String userId;
  final String? eventId;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  
  NotificationModel({
    required this.id,
    required this.userId,
    this.eventId,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });
  
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      userId: json['user_id'],
      eventId: json['event_id'],
      title: json['title'],
      message: json['message'],
      type: json['type'],
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'event_id': eventId,
      'title': title,
      'message': message,
      'type': type,
      'is_read': isRead,
    };
  }
}

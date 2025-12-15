// ================================
// FAVORITE MODEL
// ================================

class FavoriteModel {
  final String id;
  final String userId;
  final String eventId;
  final DateTime createdAt;
  
  FavoriteModel({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.createdAt,
  });
  
  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      id: json['id'],
      userId: json['user_id'],
      eventId: json['event_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'event_id': eventId,
    };
  }
}

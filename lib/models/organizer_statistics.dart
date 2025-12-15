// ================================
// ORGANIZER STATISTICS MODEL
// ================================

class OrganizerStatisticsModel {
  final String id;
  final String organizerId;
  final int totalEvents;
  final int totalAttendees;
  final double totalRevenue;
  final double averageRating;
  final int totalReviews;
  final DateTime lastUpdated;
  
  OrganizerStatisticsModel({
    required this.id,
    required this.organizerId,
    required this.totalEvents,
    required this.totalAttendees,
    required this.totalRevenue,
    required this.averageRating,
    required this.totalReviews,
    required this.lastUpdated,
  });
  
  factory OrganizerStatisticsModel.fromJson(Map<String, dynamic> json) {
    return OrganizerStatisticsModel(
      id: json['id'],
      organizerId: json['organizer_id'],
      totalEvents: json['total_events'] ?? 0,
      totalAttendees: json['total_attendees'] ?? 0,
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0.0,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['total_reviews'] ?? 0,
      lastUpdated: DateTime.parse(json['last_updated']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'organizer_id': organizerId,
      'total_events': totalEvents,
      'total_attendees': totalAttendees,
      'total_revenue': totalRevenue,
      'average_rating': averageRating,
      'total_reviews': totalReviews,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }
}

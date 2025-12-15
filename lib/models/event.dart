// ================================
// EVENT MODEL
// ================================

class EventModel {
  final String id;
  final String organizerId;
  final String title;
  final String description;
  final String category;
  final String location;
  final String venue;
  final DateTime eventDate;
  final DateTime? endDate;
  final String? imageUrl;
  final double ticketPrice;
  final int totalSeats;
  final int availableSeats;
  final bool isPublished;
  final String status;
  final DateTime createdAt;
  
  EventModel({
    required this.id,
    required this.organizerId,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.venue,
    required this.eventDate,
    this.endDate,
    this.imageUrl,
    required this.ticketPrice,
    required this.totalSeats,
    required this.availableSeats,
    required this.isPublished,
    required this.status,
    required this.createdAt,
  });
  
  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'],
      organizerId: json['organizer_id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      location: json['location'],
      venue: json['venue'],
      eventDate: DateTime.parse(json['event_date']),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      imageUrl: json['image_url'],
      ticketPrice: (json['ticket_price'] as num).toDouble(),
      totalSeats: json['total_seats'],
      availableSeats: json['available_seats'],
      isPublished: json['is_published'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'organizer_id': organizerId,
      'title': title,
      'description': description,
      'category': category,
      'location': location,
      'venue': venue,
      'event_date': eventDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'image_url': imageUrl,
      'ticket_price': ticketPrice,
      'total_seats': totalSeats,
      'available_seats': availableSeats,
      'is_published': isPublished,
      'status': status,
    };
  }
}

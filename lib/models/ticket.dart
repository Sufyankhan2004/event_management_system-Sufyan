// ================================
// TICKET MODEL
// ================================

class TicketModel {
  final String id;
  final String registrationId;
  final String userId;
  final String eventId;
  final String ticketCode;
  final String qrCodeData;
  final String ticketType;
  final double price;
  final bool isUsed;
  final DateTime? usedAt;
  final DateTime createdAt;
  
  TicketModel({
    required this.id,
    required this.registrationId,
    required this.userId,
    required this.eventId,
    required this.ticketCode,
    required this.qrCodeData,
    required this.ticketType,
    required this.price,
    required this.isUsed,
    this.usedAt,
    required this.createdAt,
  });
  
  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'],
      registrationId: json['registration_id'],
      userId: json['user_id'],
      eventId: json['event_id'],
      ticketCode: json['ticket_code'],
      qrCodeData: json['qr_code_data'],
      ticketType: json['ticket_type'] ?? 'standard',
      price: (json['price'] as num).toDouble(),
      isUsed: json['is_used'] ?? false,
      usedAt: json['used_at'] != null ? DateTime.parse(json['used_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'registration_id': registrationId,
      'user_id': userId,
      'event_id': eventId,
      'ticket_code': ticketCode,
      'qr_code_data': qrCodeData,
      'ticket_type': ticketType,
      'price': price,
      'is_used': isUsed,
      'used_at': usedAt?.toIso8601String(),
    };
  }
}

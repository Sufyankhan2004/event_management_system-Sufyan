// ================================
// REGISTRATION MODEL
// ================================

class RegistrationModel {
  final String id;
  final String eventId;
  final String userId;
  final String ticketCode;
  final String qrCodeData;
  final int numberOfTickets;
  final double totalAmount;
  final String paymentStatus;
  final bool checkedIn;
  final DateTime? checkedInAt;
  final DateTime createdAt;
  
  RegistrationModel({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.ticketCode,
    required this.qrCodeData,
    required this.numberOfTickets,
    required this.totalAmount,
    required this.paymentStatus,
    required this.checkedIn,
    this.checkedInAt,
    required this.createdAt,
  });
  
  factory RegistrationModel.fromJson(Map<String, dynamic> json) {
    return RegistrationModel(
      id: json['id'],
      eventId: json['event_id'],
      userId: json['user_id'],
      ticketCode: json['ticket_code'],
      qrCodeData: json['qr_code_data'],
      numberOfTickets: json['number_of_tickets'],
      totalAmount: (json['total_amount'] as num).toDouble(),
      paymentStatus: json['payment_status'],
      checkedIn: json['checked_in'],
      checkedInAt: json['checked_in_at'] != null ? DateTime.parse(json['checked_in_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

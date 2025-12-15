// ================================
// PAYMENT MODEL
// ================================

class PaymentModel {
  final String id;
  final String registrationId;
  final String userId;
  final String eventId;
  final double amount;
  final String paymentMethod;
  final String paymentStatus;
  final String? transactionId;
  final String? paymentGateway;
  final DateTime? paidAt;
  final DateTime createdAt;
  
  PaymentModel({
    required this.id,
    required this.registrationId,
    required this.userId,
    required this.eventId,
    required this.amount,
    required this.paymentMethod,
    required this.paymentStatus,
    this.transactionId,
    this.paymentGateway,
    this.paidAt,
    required this.createdAt,
  });
  
  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],
      registrationId: json['registration_id'],
      userId: json['user_id'],
      eventId: json['event_id'],
      amount: (json['amount'] as num).toDouble(),
      paymentMethod: json['payment_method'],
      paymentStatus: json['payment_status'],
      transactionId: json['transaction_id'],
      paymentGateway: json['payment_gateway'],
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'registration_id': registrationId,
      'user_id': userId,
      'event_id': eventId,
      'amount': amount,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'transaction_id': transactionId,
      'payment_gateway': paymentGateway,
      'paid_at': paidAt?.toIso8601String(),
    };
  }
}

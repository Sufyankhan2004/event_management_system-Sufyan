import '../models/payment.dart';
import 'base_service.dart';
import 'registration_service.dart';

// ================================
// PAYMENT SERVICE
// ================================
// Handles payment and transaction operations

class PaymentService extends BaseService {
  PaymentService() : super('payments');
  
  final _registrationService = RegistrationService();
  
  // Create a payment record
  Future<PaymentModel> createPayment({
    required String registrationId,
    required String eventId,
    required double amount,
    required String paymentMethod,
    String paymentStatus = 'pending',
    String? transactionId,
    String? paymentGateway,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');
      
      final paymentData = {
        'registration_id': registrationId,
        'user_id': userId,
        'event_id': eventId,
        'amount': amount,
        'payment_method': paymentMethod,
        'payment_status': paymentStatus,
        'transaction_id': transactionId,
        'payment_gateway': paymentGateway,
      };
      
      final response = await create(paymentData);
      return PaymentModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create payment: ${e.toString()}');
    }
  }
  
  // Get payment by ID
  Future<PaymentModel?> getPayment(String paymentId) async {
    try {
      final data = await getById(paymentId);
      if (data == null) return null;
      return PaymentModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get payment: ${e.toString()}');
    }
  }
  
  // Get payment by registration ID
  Future<PaymentModel?> getPaymentByRegistration(String registrationId) async {
    try {
      final payments = await query(
        filters: {'registration_id': registrationId},
        limit: 1,
      );
      
      if (payments.isEmpty) return null;
      return PaymentModel.fromJson(payments.first);
    } catch (e) {
      throw Exception('Failed to get payment by registration: ${e.toString()}');
    }
  }
  
  // Get user's payments
  Future<List<PaymentModel>> getUserPayments({String? userId}) async {
    try {
      final targetUserId = userId ?? currentUserId;
      if (targetUserId == null) throw Exception('User not authenticated');
      
      final data = await query(
        filters: {'user_id': targetUserId},
        orderBy: 'created_at',
        ascending: false,
      );
      return data.map((json) => PaymentModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get user payments: ${e.toString()}');
    }
  }
  
  // Get payments for an event
  Future<List<PaymentModel>> getEventPayments(String eventId) async {
    try {
      final data = await query(
        filters: {'event_id': eventId},
        orderBy: 'created_at',
        ascending: false,
      );
      return data.map((json) => PaymentModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get event payments: ${e.toString()}');
    }
  }
  
  // Update payment status
  Future<PaymentModel> updatePaymentStatus(
    String paymentId,
    String status, {
    String? transactionId,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'payment_status': status,
      };
      
      if (status == 'completed') {
        updateData['paid_at'] = DateTime.now().toIso8601String();
      }
      
      if (transactionId != null) {
        updateData['transaction_id'] = transactionId;
      }
      
      final response = await update(paymentId, updateData);
      final payment = PaymentModel.fromJson(response);
      
      // Update registration payment status
      await _registrationService.updatePaymentStatus(
        payment.registrationId,
        status,
      );
      
      return payment;
    } catch (e) {
      throw Exception('Failed to update payment status: ${e.toString()}');
    }
  }
  
  // Process payment (mock implementation - integrate with real payment gateway)
  Future<PaymentModel> processPayment({
    required String registrationId,
    required String eventId,
    required double amount,
    required String paymentMethod,
    String? paymentGateway,
  }) async {
    try {
      // Create payment record
      final payment = await createPayment(
        registrationId: registrationId,
        eventId: eventId,
        amount: amount,
        paymentMethod: paymentMethod,
        paymentStatus: 'processing',
        paymentGateway: paymentGateway,
      );
      
      // Simulate payment processing
      // In a real application, this would integrate with a payment gateway
      // like Stripe, PayPal, Razorpay, etc.
      
      // For now, mark as completed (this is just a mock)
      final completedPayment = await updatePaymentStatus(
        payment.id,
        'completed',
        transactionId: 'TXN${DateTime.now().millisecondsSinceEpoch}',
      );
      
      return completedPayment;
    } catch (e) {
      throw Exception('Failed to process payment: ${e.toString()}');
    }
  }
  
  // Refund payment
  Future<PaymentModel> refundPayment(String paymentId) async {
    try {
      final payment = await getPayment(paymentId);
      if (payment == null) throw Exception('Payment not found');
      
      if (payment.paymentStatus != 'completed') {
        throw Exception('Only completed payments can be refunded');
      }
      
      final response = await update(paymentId, {
        'payment_status': 'refunded',
      });
      
      return PaymentModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to refund payment: ${e.toString()}');
    }
  }
  
  // Get total revenue for an event
  Future<double> getEventRevenue(String eventId) async {
    try {
      final payments = await getEventPayments(eventId);
      double revenue = 0.0;
      
      for (final payment in payments) {
        if (payment.paymentStatus == 'completed') {
          revenue += payment.amount;
        }
      }
      
      return revenue;
    } catch (e) {
      return 0.0;
    }
  }
  
  // Get user's total spending
  Future<double> getUserTotalSpending({String? userId}) async {
    try {
      final payments = await getUserPayments(userId: userId);
      double total = 0.0;
      
      for (final payment in payments) {
        if (payment.paymentStatus == 'completed') {
          total += payment.amount;
        }
      }
      
      return total;
    } catch (e) {
      return 0.0;
    }
  }
  
  // Get payment statistics
  Future<Map<String, dynamic>> getPaymentStatistics({String? eventId, String? userId}) async {
    try {
      List<PaymentModel> payments;
      
      if (eventId != null) {
        payments = await getEventPayments(eventId);
      } else if (userId != null) {
        payments = await getUserPayments(userId: userId);
      } else {
        final data = await getAll();
        payments = data.map((json) => PaymentModel.fromJson(json)).toList();
      }
      
      int total = payments.length;
      int completed = payments.where((p) => p.paymentStatus == 'completed').length;
      int pending = payments.where((p) => p.paymentStatus == 'pending').length;
      int failed = payments.where((p) => p.paymentStatus == 'failed').length;
      double totalAmount = payments
          .where((p) => p.paymentStatus == 'completed')
          .fold(0.0, (sum, p) => sum + p.amount);
      
      return {
        'total_payments': total,
        'completed_payments': completed,
        'pending_payments': pending,
        'failed_payments': failed,
        'total_revenue': totalAmount,
      };
    } catch (e) {
      throw Exception('Failed to get payment statistics: ${e.toString()}');
    }
  }
}

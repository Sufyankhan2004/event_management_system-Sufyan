// ================================
// PAYMENT SERVICE
// ================================

import '../config/supabase_config.dart';

class PaymentService {
  // Process payment for registration
  Future<Map<String, dynamic>> processPayment({
    required String registrationId,
    required String eventId,
    required double amount,
    required String paymentMethod,
  }) async {
    try {
      // Create payment record
      final response = await supabase
          .from('payments')
          .insert({
            'registration_id': registrationId,
            'event_id': eventId,
            'amount': amount,
            'payment_method': paymentMethod,
            'payment_status': 'completed',
            'paid_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      // Update registration payment status
      await supabase
          .from('registrations')
          .update({'payment_status': 'completed'})
          .eq('id', registrationId);

      return {'success': true, 'payment_id': response['id']};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Get payment by ID
  Future<Map<String, dynamic>?> getPaymentById(String paymentId) async {
    try {
      final response = await supabase
          .from('payments')
          .select()
          .eq('id', paymentId)
          .maybeSingle();
      return response;
    } catch (e) {
      throw Exception('Failed to get payment: ${e.toString()}');
    }
  }

  // Get payments for registration
  Future<List<Map<String, dynamic>>> getRegistrationPayments(
      String registrationId) async {
    try {
      final data = await supabase
          .from('payments')
          .select()
          .eq('registration_id', registrationId)
          .order('paid_at', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      throw Exception('Failed to get payments: ${e.toString()}');
    }
  }

  // Get payments for event
  Future<List<Map<String, dynamic>>> getEventPayments(String eventId) async {
    try {
      final data = await supabase
          .from('payments')
          .select()
          .eq('event_id', eventId)
          .eq('payment_status', 'completed')
          .order('paid_at', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      throw Exception('Failed to get event payments: ${e.toString()}');
    }
  }

  // Get total revenue for event
  Future<double> getEventRevenue(String eventId) async {
    try {
      final data = await supabase
          .from('payments')
          .select('amount')
          .eq('event_id', eventId)
          .eq('payment_status', 'completed');

      double total = 0;
      for (var payment in data) {
        total += (payment['amount'] as num).toDouble();
      }
      return total;
    } catch (e) {
      throw Exception('Failed to calculate revenue: ${e.toString()}');
    }
  }

  // Refund payment
  Future<bool> refundPayment(String paymentId) async {
    try {
      await supabase
          .from('payments')
          .update({'payment_status': 'refunded'})
          .eq('id', paymentId);
      return true;
    } catch (e) {
      return false;
    }
  }
}
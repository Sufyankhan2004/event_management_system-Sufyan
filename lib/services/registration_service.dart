// ================================
// REGISTRATION SERVICE
// ================================

import 'package:event_semester_sufyan/models/registration.dart';

import '../config/supabase_config.dart';
import '../models/event.dart';

class RegistrationService {
  // Register for event
  Future<Map<String, dynamic>> registerForEvent(String userId, String eventId) async {
    try {
      // Check if already registered
      final existing = await supabase
          .from('registrations')
          .select()
          .eq('user_id', userId)
          .eq('event_id', eventId)
          .maybeSingle();
      
      if (existing != null) {
        return {'success': false, 'error': 'Already registered for this event'};
      }

      // Generate ticket code
      final ticketCode = 'TKT-${DateTime.now().millisecondsSinceEpoch}';

      // Create registration
      final response = await supabase
          .from('registrations')
          .insert({
            'user_id': userId,
            'event_id': eventId,
            'ticket_code': ticketCode,
            'checked_in': false,
          })
          .select()
          .single();

      // Update available seats
      await supabase.rpc('decrement_available_seats', params: {'event_id': eventId});

      return {'success': true, 'ticket_code': response['ticket_code']};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Create registration with payment details
  Future<RegistrationModel> createRegistration({
    required String eventId,
    required int numberOfTickets,
    required double totalAmount,
    required String paymentStatus,
  }) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Generate ticket code
      final ticketCode = 'TKT-${DateTime.now().millisecondsSinceEpoch}';

      // Create registration
      final response = await supabase
          .from('registrations')
          .insert({
            'user_id': userId,
            'event_id': eventId,
            'ticket_code': ticketCode,
            'number_of_tickets': numberOfTickets,
            'total_amount': totalAmount,
            'payment_status': paymentStatus,
            'checked_in': false,
          })
          .select()
          .single();

      // Update available seats
      await supabase.rpc('decrement_available_seats', 
        params: {'event_id': eventId, 'count': numberOfTickets});

      return RegistrationModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create registration: ${e.toString()}');
    }
  }

  // Get user registrations
  Future<List<Map<String, dynamic>>> getUserRegistrations(String userId) async {
    final data = await supabase
        .from('registrations')
        .select('*, events(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    
    return List<Map<String, dynamic>>.from(data);
  }

  // Get event attendees
  Future<List<Map<String, dynamic>>> getEventAttendees(String eventId) async {
    final data = await supabase
        .from('registrations')
        .select('*, profiles(*)')
        .eq('event_id', eventId)
        .order('created_at', ascending: false);
    
    return List<Map<String, dynamic>>.from(data);
  }

  // Check in attendee
  Future<bool> checkInAttendee(String registrationId) async {
    try {
      await supabase
          .from('registrations')
          .update({'checked_in': true})
          .eq('id', registrationId);
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // Cancel registration
  Future<bool> cancelRegistration(String userId, String eventId) async {
    try {
      await supabase
          .from('registrations')
          .delete()
          .eq('user_id', userId)
          .eq('event_id', eventId);

      // Increment available seats
      await supabase.rpc('increment_available_seats', params: {'event_id': eventId});

      return true;
    } catch (e) {
      return false;
    }
  }

  // Check if user is registered for event
  Future<bool> isUserRegistered(String userId, String eventId) async {
    try {
      final data = await supabase
          .from('registrations')
          .select()
          .eq('user_id', userId)
          .eq('event_id', eventId)
          .maybeSingle();
      
      return data != null;
    } catch (e) {
      return false;
    }
  }
}

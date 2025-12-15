// ================================
// TICKET SERVICE
// ================================

import '../config/supabase_config.dart';
import '../models/ticket.dart';

class TicketService {
  // Generate tickets for a registration
  Future<List<TicketModel>> generateTickets({
    required String registrationId,
    required String eventId,
    required int numberOfTickets,
    required double pricePerTicket,
  }) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final List<TicketModel> generatedTickets = [];

      for (int i = 0; i < numberOfTickets; i++) {
        // Generate unique ticket code
        final ticketCode = 'TKT-${DateTime.now().millisecondsSinceEpoch}-$i';
        // Generate QR code data (simple version)
        final qrCodeData = '$registrationId-$ticketCode';

        final response = await supabase
            .from('tickets')
            .insert({
              'registration_id': registrationId,
              'user_id': userId,
              'event_id': eventId,
              'ticket_code': ticketCode,
              'qr_code_data': qrCodeData,
              'ticket_type': 'standard',
              'price': pricePerTicket,
              'is_used': false,
            })
            .select()
            .single();

        generatedTickets.add(TicketModel.fromJson(response));
      }

      return generatedTickets;
    } catch (e) {
      throw Exception('Failed to generate tickets: ${e.toString()}');
    }
  }

  // Get tickets for a registration
  Future<List<TicketModel>> getRegistrationTickets(String registrationId) async {
    try {
      final data = await supabase
          .from('tickets')
          .select()
          .eq('registration_id', registrationId);

      return (data as List)
          .map((ticket) => TicketModel.fromJson(ticket))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch tickets: ${e.toString()}');
    }
  }

  // Get ticket by code
  Future<TicketModel?> getTicketByCode(String ticketCode) async {
    try {
      final data = await supabase
          .from('tickets')
          .select()
          .eq('ticket_code', ticketCode)
          .maybeSingle();

      if (data == null) return null;
      return TicketModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to fetch ticket: ${e.toString()}');
    }
  }

  // Get user tickets
  Future<List<TicketModel>> getUserTickets(String userId) async {
    try {
      final data = await supabase
          .from('tickets')
          .select()
          .eq('user_id', userId)
          .eq('is_used', false)
          .order('created_at', ascending: false);

      return (data as List)
          .map((ticket) => TicketModel.fromJson(ticket))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch user tickets: ${e.toString()}');
    }
  }

  // Mark ticket as used
  Future<void> markTicketAsUsed(String ticketId) async {
    try {
      await supabase
          .from('tickets')
          .update({
            'is_used': true,
            'used_at': DateTime.now().toIso8601String(),
          })
          .eq('id', ticketId);
    } catch (e) {
      throw Exception('Failed to mark ticket as used: ${e.toString()}');
    }
  }

  // Delete ticket
  Future<void> deleteTicket(String ticketId) async {
    try {
      await supabase.from('tickets').delete().eq('id', ticketId);
    } catch (e) {
      throw Exception('Failed to delete ticket: ${e.toString()}');
    }
  }
}
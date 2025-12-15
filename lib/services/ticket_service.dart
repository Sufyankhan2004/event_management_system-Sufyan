import 'package:uuid/uuid.dart';
import '../models/ticket.dart';
import 'base_service.dart';

// ================================
// TICKET SERVICE
// ================================
// Handles ticket generation and management

class TicketService extends BaseService {
  TicketService() : super('tickets');
  
  final _uuid = const Uuid();
  
  // Generate tickets for a registration
  Future<List<TicketModel>> generateTickets({
    required String registrationId,
    required String eventId,
    required int numberOfTickets,
    required double pricePerTicket,
    String ticketType = 'standard',
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');
      
      final tickets = <TicketModel>[];
      
      for (int i = 0; i < numberOfTickets; i++) {
        final ticketCode = _uuid.v4().substring(0, 10).toUpperCase();
        final qrCodeData = 'TICKET:$ticketCode|EVENT:$eventId|USER:$userId';
        
        final ticketData = {
          'registration_id': registrationId,
          'user_id': userId,
          'event_id': eventId,
          'ticket_code': ticketCode,
          'qr_code_data': qrCodeData,
          'ticket_type': ticketType,
          'price': pricePerTicket,
          'is_used': false,
        };
        
        final response = await create(ticketData);
        tickets.add(TicketModel.fromJson(response));
      }
      
      return tickets;
    } catch (e) {
      throw Exception('Failed to generate tickets: ${e.toString()}');
    }
  }
  
  // Get ticket by ID
  Future<TicketModel?> getTicket(String ticketId) async {
    try {
      final data = await getById(ticketId);
      if (data == null) return null;
      return TicketModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get ticket: ${e.toString()}');
    }
  }
  
  // Get ticket by code
  Future<TicketModel?> getTicketByCode(String ticketCode) async {
    try {
      final tickets = await query(
        filters: {'ticket_code': ticketCode},
        limit: 1,
      );
      
      if (tickets.isEmpty) return null;
      return TicketModel.fromJson(tickets.first);
    } catch (e) {
      throw Exception('Failed to get ticket by code: ${e.toString()}');
    }
  }
  
  // Get tickets for a registration
  Future<List<TicketModel>> getRegistrationTickets(String registrationId) async {
    try {
      final data = await query(
        filters: {'registration_id': registrationId},
        orderBy: 'created_at',
        ascending: true,
      );
      return data.map((json) => TicketModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get registration tickets: ${e.toString()}');
    }
  }
  
  // Get user's tickets
  Future<List<TicketModel>> getUserTickets({String? userId}) async {
    try {
      final targetUserId = userId ?? currentUserId;
      if (targetUserId == null) throw Exception('User not authenticated');
      
      final data = await query(
        filters: {'user_id': targetUserId},
        orderBy: 'created_at',
        ascending: false,
      );
      return data.map((json) => TicketModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get user tickets: ${e.toString()}');
    }
  }
  
  // Get tickets for an event
  Future<List<TicketModel>> getEventTickets(String eventId) async {
    try {
      final data = await query(
        filters: {'event_id': eventId},
        orderBy: 'created_at',
        ascending: false,
      );
      return data.map((json) => TicketModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get event tickets: ${e.toString()}');
    }
  }
  
  // Mark ticket as used
  Future<TicketModel> useTicket(String ticketId) async {
    try {
      final response = await update(ticketId, {
        'is_used': true,
        'used_at': DateTime.now().toIso8601String(),
      });
      return TicketModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to use ticket: ${e.toString()}');
    }
  }
  
  // Validate and use ticket by code
  Future<TicketModel?> validateAndUseTicket(String ticketCode) async {
    try {
      final ticket = await getTicketByCode(ticketCode);
      if (ticket == null) return null;
      
      if (ticket.isUsed) {
        throw Exception('Ticket already used');
      }
      
      return await useTicket(ticket.id);
    } catch (e) {
      throw Exception('Failed to validate ticket: ${e.toString()}');
    }
  }
  
  // Check if ticket is valid
  Future<bool> isTicketValid(String ticketCode) async {
    try {
      final ticket = await getTicketByCode(ticketCode);
      return ticket != null && !ticket.isUsed;
    } catch (e) {
      return false;
    }
  }
  
  // Get used tickets count for an event
  Future<int> getUsedTicketsCount(String eventId) async {
    try {
      final response = await client
          .from(tableName)
          .select()
          .eq('event_id', eventId)
          .eq('is_used', true);
      
      return List<Map<String, dynamic>>.from(response).length;
    } catch (e) {
      return 0;
    }
  }
}

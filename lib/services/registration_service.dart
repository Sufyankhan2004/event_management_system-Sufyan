import 'package:uuid/uuid.dart';
import '../models/registration.dart';
import 'base_service.dart';
import 'event_service.dart';

// ================================
// REGISTRATION SERVICE
// ================================
// Handles event registration operations

class RegistrationService extends BaseService {
  RegistrationService() : super('registrations');
  
  final _eventService = EventService();
  final _uuid = const Uuid();
  
  // Create a new registration
  Future<RegistrationModel> createRegistration({
    required String eventId,
    required int numberOfTickets,
    required double totalAmount,
    String paymentStatus = 'pending',
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');
      
      // Generate unique ticket code and QR data
      final ticketCode = _uuid.v4().substring(0, 8).toUpperCase();
      final qrCodeData = 'EVENT:$eventId|USER:$userId|TICKET:$ticketCode';
      
      // Check if seats are available
      await _eventService.updateAvailableSeats(eventId, numberOfTickets);
      
      final registrationData = {
        'event_id': eventId,
        'user_id': userId,
        'ticket_code': ticketCode,
        'qr_code_data': qrCodeData,
        'number_of_tickets': numberOfTickets,
        'total_amount': totalAmount,
        'payment_status': paymentStatus,
        'checked_in': false,
      };
      
      final response = await create(registrationData);
      return RegistrationModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create registration: ${e.toString()}');
    }
  }
  
  // Get registration by ID
  Future<RegistrationModel?> getRegistration(String registrationId) async {
    try {
      final data = await getById(registrationId);
      if (data == null) return null;
      return RegistrationModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get registration: ${e.toString()}');
    }
  }
  
  // Get user's registrations
  Future<List<RegistrationModel>> getUserRegistrations({String? userId}) async {
    try {
      final targetUserId = userId ?? currentUserId;
      if (targetUserId == null) throw Exception('User not authenticated');
      
      final data = await query(
        filters: {'user_id': targetUserId},
        orderBy: 'created_at',
        ascending: false,
      );
      return data.map((json) => RegistrationModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get user registrations: ${e.toString()}');
    }
  }
  
  // Get registrations for an event
  Future<List<RegistrationModel>> getEventRegistrations(String eventId) async {
    try {
      final data = await query(
        filters: {'event_id': eventId},
        orderBy: 'created_at',
        ascending: false,
      );
      return data.map((json) => RegistrationModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get event registrations: ${e.toString()}');
    }
  }
  
  // Check if user is registered for an event
  Future<bool> isUserRegistered(String eventId, {String? userId}) async {
    try {
      final targetUserId = userId ?? currentUserId;
      if (targetUserId == null) return false;
      
      final data = await query(
        filters: {'event_id': eventId, 'user_id': targetUserId},
        limit: 1,
      );
      return data.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
  
  // Update registration payment status
  Future<RegistrationModel> updatePaymentStatus(String registrationId, String status) async {
    try {
      final response = await update(registrationId, {'payment_status': status});
      return RegistrationModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update payment status: ${e.toString()}');
    }
  }
  
  // Check in a registration
  Future<RegistrationModel> checkIn(String registrationId) async {
    try {
      final response = await update(registrationId, {
        'checked_in': true,
        'checked_in_at': DateTime.now().toIso8601String(),
      });
      return RegistrationModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to check in: ${e.toString()}');
    }
  }
  
  // Cancel registration
  Future<void> cancelRegistration(String registrationId) async {
    try {
      // Get registration details to return seats
      final registration = await getRegistration(registrationId);
      if (registration != null) {
        // Return seats to event
        final event = await _eventService.getEvent(registration.eventId);
        if (event != null) {
          await _eventService.update(
            registration.eventId,
            {'available_seats': event.availableSeats + registration.numberOfTickets},
          );
        }
      }
      
      await delete(registrationId);
    } catch (e) {
      throw Exception('Failed to cancel registration: ${e.toString()}');
    }
  }
  
  // Get registration count for an event
  Future<int> getEventRegistrationCount(String eventId) async {
    try {
      final registrations = await getEventRegistrations(eventId);
      return registrations.length;
    } catch (e) {
      return 0;
    }
  }
  
  // Get total attendees for an event
  Future<int> getEventAttendeesCount(String eventId) async {
    try {
      final registrations = await getEventRegistrations(eventId);
      return registrations.fold(0, (sum, reg) => sum + reg.numberOfTickets);
    } catch (e) {
      return 0;
    }
  }
}

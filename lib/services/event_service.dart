import '../models/event.dart';
import 'base_service.dart';

// ================================
// EVENT SERVICE
// ================================
// Handles event-related operations

class EventService extends BaseService {
  EventService() : super('events');
  
  // Create a new event
  Future<EventModel> createEvent(Map<String, dynamic> eventData) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');
      
      eventData['organizer_id'] = userId;
      final response = await create(eventData);
      return EventModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create event: ${e.toString()}');
    }
  }
  
  // Get event by ID
  Future<EventModel?> getEvent(String eventId) async {
    try {
      final data = await getById(eventId);
      if (data == null) return null;
      return EventModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get event: ${e.toString()}');
    }
  }
  
  // Get all published events
  Future<List<EventModel>> getPublishedEvents({int? limit}) async {
    try {
      final data = await query(
        filters: {'is_published': true},
        orderBy: 'event_date',
        ascending: true,
        limit: limit,
      );
      return data.map((json) => EventModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get published events: ${e.toString()}');
    }
  }
  
  // Get upcoming events
  Future<List<EventModel>> getUpcomingEvents({int? limit}) async {
    try {
      final now = DateTime.now().toIso8601String();
      final response = await client
          .from(tableName)
          .select()
          .eq('is_published', true)
          .gte('event_date', now)
          .order('event_date', ascending: true)
          .limit(limit ?? 10);
      
      return List<Map<String, dynamic>>.from(response)
          .map((json) => EventModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get upcoming events: ${e.toString()}');
    }
  }
  
  // Get featured events
  Future<List<EventModel>> getFeaturedEvents({int? limit}) async {
    try {
      final now = DateTime.now().toIso8601String();
      final response = await client
          .from(tableName)
          .select()
          .eq('is_published', true)
          .gte('event_date', now)
          .order('created_at', ascending: false)
          .limit(limit ?? 5);
      
      return List<Map<String, dynamic>>.from(response)
          .map((json) => EventModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get featured events: ${e.toString()}');
    }
  }
  
  // Get events by category
  Future<List<EventModel>> getEventsByCategory(String category, {int? limit}) async {
    try {
      final data = await query(
        filters: {'category': category, 'is_published': true},
        orderBy: 'event_date',
        ascending: true,
        limit: limit,
      );
      return data.map((json) => EventModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get events by category: ${e.toString()}');
    }
  }
  
  // Get events by organizer
  Future<List<EventModel>> getEventsByOrganizer(String organizerId, {int? limit}) async {
    try {
      final data = await query(
        filters: {'organizer_id': organizerId},
        orderBy: 'created_at',
        ascending: false,
        limit: limit,
      );
      return data.map((json) => EventModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get events by organizer: ${e.toString()}');
    }
  }
  
  // Get current user's events
  Future<List<EventModel>> getMyEvents({int? limit}) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');
      return await getEventsByOrganizer(userId, limit: limit);
    } catch (e) {
      throw Exception('Failed to get my events: ${e.toString()}');
    }
  }
  
  // Update event
  Future<EventModel> updateEvent(String eventId, Map<String, dynamic> data) async {
    try {
      final response = await update(eventId, data);
      return EventModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update event: ${e.toString()}');
    }
  }
  
  // Delete event
  Future<void> deleteEvent(String eventId) async {
    try {
      await delete(eventId);
    } catch (e) {
      throw Exception('Failed to delete event: ${e.toString()}');
    }
  }
  
  // Update available seats
  Future<void> updateAvailableSeats(String eventId, int seatsToReduce) async {
    try {
      final event = await getEvent(eventId);
      if (event == null) throw Exception('Event not found');
      
      final newAvailableSeats = event.availableSeats - seatsToReduce;
      if (newAvailableSeats < 0) throw Exception('Not enough seats available');
      
      await update(eventId, {'available_seats': newAvailableSeats});
    } catch (e) {
      throw Exception('Failed to update available seats: ${e.toString()}');
    }
  }
  
  // Search events
  Future<List<EventModel>> searchEvents(String query) async {
    try {
      final response = await client
          .from(tableName)
          .select()
          .eq('is_published', true)
          .or('title.ilike.%$query%,description.ilike.%$query%')
          .order('event_date', ascending: true);
      
      return List<Map<String, dynamic>>.from(response)
          .map((json) => EventModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to search events: ${e.toString()}');
    }
  }
}

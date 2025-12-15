// ================================
// EVENT SERVICE
// ================================

import '../config/supabase_config.dart';
import '../models/event.dart';

class EventService {
  // Get all published events
  Future<List<EventModel>> getPublishedEvents({int limit = 50}) async {
    final data = await supabase
        .from('events')
        .select()
        .eq('is_published', true)
        .gte('event_date', DateTime.now().toIso8601String())
        .order('event_date', ascending: true)
        .limit(limit);
    
    return data.map((e) => EventModel.fromJson(e)).toList();
  }

  // Get featured events
  Future<List<EventModel>> getFeaturedEvents({int limit = 5}) async {
    final data = await supabase
        .from('events')
        .select()
        .eq('is_published', true)
        .gte('event_date', DateTime.now().toIso8601String())
        .order('created_at', ascending: false)
        .limit(limit);
    
    return data.map((e) => EventModel.fromJson(e)).toList();
  }

  // Get events by category
  Future<List<EventModel>> getEventsByCategory(String category) async {
    final data = await supabase
        .from('events')
        .select()
        .eq('is_published', true)
        .eq('category', category)
        .gte('event_date', DateTime.now().toIso8601String())
        .order('event_date', ascending: true);
    
    return data.map((e) => EventModel.fromJson(e)).toList();
  }

  // Get organizer events
  Future<List<EventModel>> getOrganizerEvents(String organizerId) async {
    final data = await supabase
        .from('events')
        .select()
        .eq('organizer_id', organizerId)
        .order('created_at', ascending: false);
    
    return data.map((e) => EventModel.fromJson(e)).toList();
  }

  // Get event by ID
  Future<EventModel?> getEventById(String eventId) async {
    try {
      final data = await supabase
          .from('events')
          .select()
          .eq('id', eventId)
          .single();
      
      return EventModel.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  // Create event
  Future<String?> createEvent(Map<String, dynamic> eventData) async {
    try {
      final response = await supabase
          .from('events')
          .insert(eventData)
          .select()
          .single();
      
      return response['id'];
    } catch (e) {
      return null;
    }
  }

  // Update event
  Future<bool> updateEvent(String eventId, Map<String, dynamic> updates) async {
    try {
      await supabase
          .from('events')
          .update(updates)
          .eq('id', eventId);
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // Delete event
  Future<bool> deleteEvent(String eventId) async {
    try {
      await supabase
          .from('events')
          .delete()
          .eq('id', eventId);
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // Search events
  Future<List<EventModel>> searchEvents(String query) async {
    final data = await supabase
        .from('events')
        .select()
        .eq('is_published', true)
        .or('title.ilike.%$query%,description.ilike.%$query%,location.ilike.%$query%')
        .gte('event_date', DateTime.now().toIso8601String());
    
    return data.map((e) => EventModel.fromJson(e)).toList();
  }

  // Get categories
  Future<List<String>> getCategories() async {
    final data = await supabase
        .from('event_categories')
        .select('name');
    
    return data.map((e) => e['name'] as String).toList();
  }
}

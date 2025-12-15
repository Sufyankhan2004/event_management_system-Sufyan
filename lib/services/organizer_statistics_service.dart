import '../models/organizer_statistics.dart';
import 'base_service.dart';
import 'event_service.dart';
import 'registration_service.dart';

// ================================
// ORGANIZER STATISTICS SERVICE
// ================================
// Handles organizer performance tracking

class OrganizerStatisticsService extends BaseService {
  OrganizerStatisticsService() : super('organizer_statistics');
  
  final _eventService = EventService();
  final _registrationService = RegistrationService();
  
  // Get organizer statistics
  Future<OrganizerStatisticsModel?> getOrganizerStatistics(String organizerId) async {
    try {
      final data = await query(
        filters: {'organizer_id': organizerId},
        limit: 1,
      );
      
      if (data.isEmpty) return null;
      return OrganizerStatisticsModel.fromJson(data.first);
    } catch (e) {
      throw Exception('Failed to get organizer statistics: ${e.toString()}');
    }
  }
  
  // Get current user's statistics
  Future<OrganizerStatisticsModel?> getMyStatistics() async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');
      return await getOrganizerStatistics(userId);
    } catch (e) {
      throw Exception('Failed to get my statistics: ${e.toString()}');
    }
  }
  
  // Initialize statistics for a new organizer
  Future<OrganizerStatisticsModel> initializeStatistics(String organizerId) async {
    try {
      final statsData = {
        'organizer_id': organizerId,
        'total_events': 0,
        'total_attendees': 0,
        'total_revenue': 0.0,
        'average_rating': 0.0,
        'total_reviews': 0,
        'last_updated': DateTime.now().toIso8601String(),
      };
      
      final response = await create(statsData);
      return OrganizerStatisticsModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to initialize statistics: ${e.toString()}');
    }
  }
  
  // Update organizer statistics
  Future<OrganizerStatisticsModel> updateStatistics(String organizerId) async {
    try {
      // Get all events by organizer
      final events = await _eventService.getEventsByOrganizer(organizerId);
      
      // Calculate statistics
      int totalEvents = events.length;
      int totalAttendees = 0;
      double totalRevenue = 0.0;
      
      for (final event in events) {
        // Get registrations for revenue calculation
        final registrations = await _registrationService.getEventAttendees(event.id);
        final attendees = registrations.length as int;
        totalAttendees += attendees;
        for (final registration in registrations) {
          if (registration['payment_status'] == 'completed') {
            totalRevenue += (registration['total_amount'] as num?)?.toDouble() ?? 0.0;
          }
        }
      }
      
      final statsData = {
        'total_events': totalEvents,
        'total_attendees': totalAttendees,
        'total_revenue': totalRevenue,
        'last_updated': DateTime.now().toIso8601String(),
      };
      
      // Check if statistics exist
      final existing = await getOrganizerStatistics(organizerId);
      
      if (existing == null) {
        // Create new statistics
        statsData['organizer_id'] = organizerId;
        statsData['average_rating'] = 0.0;
        statsData['total_reviews'] = 0;
        final response = await create(statsData);
        return OrganizerStatisticsModel.fromJson(response);
      } else {
        // Update existing statistics
        final response = await update(existing.id, statsData);
        return OrganizerStatisticsModel.fromJson(response);
      }
    } catch (e) {
      throw Exception('Failed to update statistics: ${e.toString()}');
    }
  }
  
  // Update rating statistics
  Future<OrganizerStatisticsModel> updateRatingStatistics(
    String organizerId,
    double averageRating,
    int totalReviews,
  ) async {
    try {
      final existing = await getOrganizerStatistics(organizerId);
      if (existing == null) throw Exception('Statistics not found');
      
      final response = await update(existing.id, {
        'average_rating': averageRating,
        'total_reviews': totalReviews,
        'last_updated': DateTime.now().toIso8601String(),
      });
      
      return OrganizerStatisticsModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update rating statistics: ${e.toString()}');
    }
  }
  
  // Increment event count
  Future<void> incrementEventCount(String organizerId) async {
    try {
      final stats = await getOrganizerStatistics(organizerId);
      if (stats == null) {
        await initializeStatistics(organizerId);
        return;
      }
      
      await update(stats.id, {
        'total_events': stats.totalEvents + 1,
        'last_updated': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to increment event count: ${e.toString()}');
    }
  }
  
  // Get top organizers by revenue
  Future<List<OrganizerStatisticsModel>> getTopOrganizersByRevenue({int limit = 10}) async {
    try {
      final data = await getAll(
        orderBy: 'total_revenue',
        ascending: false,
        limit: limit,
      );
      return data.map((json) => OrganizerStatisticsModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get top organizers: ${e.toString()}');
    }
  }
  
  // Get top organizers by rating
  Future<List<OrganizerStatisticsModel>> getTopOrganizersByRating({int limit = 10}) async {
    try {
      final data = await getAll(
        orderBy: 'average_rating',
        ascending: false,
        limit: limit,
      );
      return data.map((json) => OrganizerStatisticsModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get top rated organizers: ${e.toString()}');
    }
  }
}


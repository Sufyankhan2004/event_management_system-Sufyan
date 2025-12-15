import '../models/favorite.dart';
import 'base_service.dart';

// ================================
// FAVORITE SERVICE
// ================================
// Handles favorite events operations

class FavoriteService extends BaseService {
  FavoriteService() : super('favorites');
  
  // Add event to favorites
  Future<FavoriteModel> addToFavorites(String eventId) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');
      
      // Check if already favorited
      if (await isFavorite(eventId)) {
        throw Exception('Event already in favorites');
      }
      
      final favoriteData = {
        'user_id': userId,
        'event_id': eventId,
      };
      
      final response = await create(favoriteData);
      return FavoriteModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to add to favorites: ${e.toString()}');
    }
  }
  
  // Remove event from favorites
  Future<void> removeFromFavorites(String eventId) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');
      
      final favorites = await query(
        filters: {'user_id': userId, 'event_id': eventId},
        limit: 1,
      );
      
      if (favorites.isNotEmpty) {
        await delete(favorites.first['id']);
      }
    } catch (e) {
      throw Exception('Failed to remove from favorites: ${e.toString()}');
    }
  }
  
  // Check if event is favorited by user
  Future<bool> isFavorite(String eventId, {String? userId}) async {
    try {
      final targetUserId = userId ?? currentUserId;
      if (targetUserId == null) return false;
      
      final favorites = await query(
        filters: {'user_id': targetUserId, 'event_id': eventId},
        limit: 1,
      );
      
      return favorites.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
  
  // Get user's favorite events
  Future<List<FavoriteModel>> getUserFavorites({String? userId}) async {
    try {
      final targetUserId = userId ?? currentUserId;
      if (targetUserId == null) throw Exception('User not authenticated');
      
      final data = await query(
        filters: {'user_id': targetUserId},
        orderBy: 'created_at',
        ascending: false,
      );
      return data.map((json) => FavoriteModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get favorites: ${e.toString()}');
    }
  }
  
  // Get favorite events with event details
  Future<List<Map<String, dynamic>>> getUserFavoritesWithEvents({String? userId}) async {
    try {
      final targetUserId = userId ?? currentUserId;
      if (targetUserId == null) throw Exception('User not authenticated');
      
      final response = await client
          .from(tableName)
          .select('*, events(*)')
          .eq('user_id', targetUserId)
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get favorites with events: ${e.toString()}');
    }
  }
  
  // Toggle favorite
  Future<bool> toggleFavorite(String eventId) async {
    try {
      final isFav = await isFavorite(eventId);
      if (isFav) {
        await removeFromFavorites(eventId);
        return false;
      } else {
        await addToFavorites(eventId);
        return true;
      }
    } catch (e) {
      throw Exception('Failed to toggle favorite: ${e.toString()}');
    }
  }
  
  // Get favorite count for an event
  Future<int> getEventFavoriteCount(String eventId) async {
    try {
      final favorites = await query(filters: {'event_id': eventId});
      return favorites.length;
    } catch (e) {
      return 0;
    }
  }
}

import '../models/user_profile.dart';
import 'base_service.dart';

// ================================
// USER SERVICE
// ================================
// Handles user profile operations

class UserService extends BaseService {
  UserService() : super('profiles');
  
  // Get user profile by ID
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final data = await getById(userId);
      if (data == null) return null;
      return UserProfile.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get user profile: ${e.toString()}');
    }
  }
  
  // Get current user profile
  Future<UserProfile?> getCurrentUserProfile() async {
    try {
      final userId = currentUserId;
      if (userId == null) return null;
      return await getUserProfile(userId);
    } catch (e) {
      throw Exception('Failed to get current user profile: ${e.toString()}');
    }
  }
  
  // Update user profile
  Future<UserProfile> updateUserProfile(String userId, Map<String, dynamic> data) async {
    try {
      final response = await update(userId, data);
      return UserProfile.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update user profile: ${e.toString()}');
    }
  }
  
  // Update current user profile
  Future<UserProfile?> updateCurrentUserProfile(Map<String, dynamic> data) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');
      return await updateUserProfile(userId, data);
    } catch (e) {
      throw Exception('Failed to update current user profile: ${e.toString()}');
    }
  }
  
  // Check if user is organizer
  Future<bool> isOrganizer(String userId) async {
    try {
      final profile = await getUserProfile(userId);
      return profile?.role == 'organizer';
    } catch (e) {
      return false;
    }
  }
  
  // Get all organizers
  Future<List<UserProfile>> getOrganizers() async {
    try {
      final data = await getAll(filters: {'role': 'organizer'});
      return data.map((json) => UserProfile.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get organizers: ${e.toString()}');
    }
  }
}

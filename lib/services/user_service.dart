// ================================
// USER SERVICE
// ================================

import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/user_profile.dart';

class UserService {
  // Update user profile
  Future<void> updateUserProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    try {
      await supabase.from('profiles').update(data).eq('id', userId);
    } catch (e) {
      throw Exception('Failed to update user profile: ${e.toString()}');
    }
  }

  // Get user profile by ID
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return UserProfile.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get user profile: ${e.toString()}');
    }
  }

  // Get current user profile
  Future<UserProfile?> getCurrentUserProfile() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return null;
    return await getUserProfile(userId);
  }

  // Update user role
  Future<void> updateUserRole(String userId, String role) async {
    try {
      await supabase
          .from('profiles')
          .update({'role': role})
          .eq('id', userId);
    } catch (e) {
      throw Exception('Failed to update user role: ${e.toString()}');
    }
  }

  // Update user phone
  Future<void> updateUserPhone(String userId, String phone) async {
    try {
      await supabase
          .from('profiles')
          .update({'phone': phone})
          .eq('id', userId);
    } catch (e) {
      throw Exception('Failed to update user phone: ${e.toString()}');
    }
  }
}
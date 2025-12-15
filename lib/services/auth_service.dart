// ================================
// AUTH SERVICE
// ================================

import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/user_profile.dart';

class AuthService {
  // Sign in
  Future<UserProfile?> signIn(String email, String password) async {
    final response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    
    if (response.user != null) {
      return await getUserProfile(response.user!.id);
    }
    return null;
  }

  // Sign up
  Future<UserProfile?> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String role,
  }) async {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
    
    if (response.user != null) {
      // Update profile with role
      await supabase.from('profiles').update({
        'phone': phone,
        'role': role,
      }).eq('id', response.user!.id);
      
      return await getUserProfile(response.user!.id);
    }
    return null;
  }

  // Get user profile
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return UserProfile.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  // Get current user profile
  Future<UserProfile?> getCurrentUserProfile() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return null;
    return await getUserProfile(userId);
  }

  // Sign out
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  // Check if user is authenticated
  bool isAuthenticated() {
    return supabase.auth.currentSession != null;
  }

  // Get current user ID
  String? getCurrentUserId() {
    return supabase.auth.currentUser?.id;
  }
}

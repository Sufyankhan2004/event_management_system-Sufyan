import 'package:supabase_flutter/supabase_flutter.dart';

// ================================
// AUTHENTICATION ERROR HANDLER
// ================================

/// Converts authentication exceptions to user-friendly error messages
class AuthErrorHandler {
  /// Get a user-friendly error message from an AuthException
  static String getErrorMessage(AuthException e, {bool isSignUp = false}) {
    final message = e.message.toLowerCase();
    
    // Check for invalid credentials
    if (message.contains('invalid login credentials') || 
        (e.statusCode != null && e.statusCode == '400')) {
      return 'Invalid credentials. Please check your email and password.';
    }
    
    // Check for unverified email
    if (message.contains('email not confirmed')) {
      return 'Please verify your email address before logging in.';
    }
    
    // Check for duplicate registration (signup specific)
    if (isSignUp && (message.contains('already registered') || 
        message.contains('user already registered'))) {
      return 'This email is already registered. Please sign in instead.';
    }
    
    // Check for invalid email format
    if (message.contains('invalid email')) {
      return 'Please enter a valid email address.';
    }
    
    // Check for password requirements
    if (message.contains('password')) {
      return 'Password does not meet requirements. Please use a stronger password.';
    }
    
    // Check for network errors
    if (message.contains('network')) {
      return 'Network error. Please check your internet connection.';
    }
    
    // Default error message
    return isSignUp 
        ? 'Sign up failed. Please try again later.'
        : 'Login failed. Please try again later.';
  }
}

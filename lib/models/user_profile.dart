// ================================
// USER PROFILE MODEL
// ================================

class UserProfile {
  final String id;
  final String fullName;
  final String? phone;
  final String role;
  final String? avatarUrl;
  
  UserProfile({
    required this.id,
    required this.fullName,
    this.phone,
    required this.role,
    this.avatarUrl,
  });
  
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      fullName: json['full_name'],
      phone: json['phone'],
      role: json['role'],
      avatarUrl: json['avatar_url'],
    );
  }
}

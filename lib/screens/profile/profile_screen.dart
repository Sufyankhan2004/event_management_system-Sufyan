import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/app_theme.dart';
import '../../config/supabase_config.dart';
import '../../models/user_profile.dart';
import '../../services/user_service.dart';
import '../../services/registration_service.dart';
import '../../services/favorite_service.dart';
import '../../services/event_service.dart';
import '../auth/login_screen.dart';
import '../notifications/notifications_screen.dart';
import 'favorites_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _profile;
  bool _isLoading = true;
  int _registeredCount = 0;
  int _favoritesCount = 0;
  int _createdEventsCount = 0;
  
  final _userService = UserService();
  final _registrationService = RegistrationService();
  final _favoriteService = FavoriteService();
  final _eventService = EventService();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Load profile
      _profile = await _userService.getUserProfile(userId);

      // Load stats
      final registrations = await _registrationService.getUserRegistrations(userId);
      final favorites = await _favoriteService.getUserFavorites();

      _registeredCount = registrations.length;
      _favoritesCount = favorites.length;

      if (_profile?.role == 'organizer') {
        final events = await _eventService.getMyEvents();
        _createdEventsCount = events.length;
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await supabase.auth.signOut();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppTheme.primaryColor,
                    child: Text(
                      _profile?.fullName[0].toUpperCase() ?? 'U',
                      style: const TextStyle(
                        fontSize: 36,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _profile?.fullName ?? 'User',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    supabase.auth.currentUser?.email ?? '',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(
                      _profile?.role == 'organizer' ? 'Event Organizer' : 'Event Attendee',
                    ),
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    labelStyle: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Registered',
                  _registeredCount.toString(),
                  Icons.event,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Favorites',
                  _favoritesCount.toString(),
                  Icons.favorite,
                ),
              ),
              if (_profile?.role == 'organizer') ...[
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Created',
                    _createdEventsCount.toString(),
                    Icons.create,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),
          
          // Menu Items
          _buildMenuItem(
            Icons.person_outline,
            'Edit Profile',
            () {
              // Navigate to edit profile
            },
          ),
          _buildMenuItem(
            Icons.favorite_outline,
            'My Favorites',
            () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const FavoritesScreen()),
              );
            },
          ),
          _buildMenuItem(
            Icons.notifications_none,
            'Notifications',
            () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const NotificationsScreen()),
              );
            },
          ),
          _buildMenuItem(
            Icons.settings_outlined,
            'Settings',
            () {
              // Navigate to settings
            },
          ),
          _buildMenuItem(
            Icons.help_outline,
            'Help & Support',
            () {
              // Navigate to help
            },
          ),
          _buildMenuItem(
            Icons.info_outline,
            'About',
            () {
              // Navigate to about
            },
          ),
          const SizedBox(height: 16),
          
          // Sign Out Button
          ElevatedButton(
            onPressed: _signOut,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Sign Out',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

// ================================
// SEARCH SCREEN
// ================================


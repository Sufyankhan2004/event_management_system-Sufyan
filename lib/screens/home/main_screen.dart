import 'package:flutter/material.dart';

import '../../config/app_theme.dart';
import '../../config/supabase_config.dart';
import '../../models/user_profile.dart';
import 'home_screen.dart';
import '../events/my_events_screen.dart';
import '../search/search_screen.dart';
import '../profile/profile_screen.dart';
import '../events/create_event_screen.dart';

// ================================
// MAIN SCREEN WITH BOTTOM NAVIGATION
// ================================

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  UserProfile? _userProfile;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId != null) {
      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      setState(() {
        _userProfile = UserProfile.fromJson(data);
      });
    }
  }

  List<Widget> get _screens => [
    const HomeScreen(),
    const MyEventsScreen(),
    const SearchScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event),
            label: 'My Events',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: _userProfile?.role == 'organizer' && _selectedIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const CreateEventScreen()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Event'),
              backgroundColor: AppTheme.primaryColor,
            )
          : null,
    );
  }
}

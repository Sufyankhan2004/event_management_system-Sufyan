// ================================
// ORGANIZER MAIN SCREEN
// ================================

import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import 'organizer_dashboard_screen.dart';
import 'organizer_events_screen.dart';
import 'organizer_profile_screen.dart';
import '../screens/events/create_event_screen.dart';

class OrganizerMainScreen extends StatefulWidget {
  const OrganizerMainScreen({super.key});

  @override
  State<OrganizerMainScreen> createState() => _OrganizerMainScreenState();
}

class _OrganizerMainScreenState extends State<OrganizerMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    OrganizerDashboardScreen(),
    OrganizerEventsScreen(),
    OrganizerProfileScreen(),
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
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event),
            label: 'My Events',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 1
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

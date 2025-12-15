// ================================
// ATTENDEE MAIN SCREEN
// ================================

import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import 'attendee_home_screen.dart';
import 'attendee_events_screen.dart';
import 'attendee_search_screen.dart';
import 'attendee_profile_screen.dart';

class AttendeeMainScreen extends StatefulWidget {
  const AttendeeMainScreen({super.key});

  @override
  State<AttendeeMainScreen> createState() => _AttendeeMainScreenState();
}

class _AttendeeMainScreenState extends State<AttendeeMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    AttendeeHomeScreen(),
    AttendeeEventsScreen(),
    AttendeeSearchScreen(),
    AttendeeProfileScreen(),
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
    );
  }
}

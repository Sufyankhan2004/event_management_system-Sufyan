import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/app_theme.dart';
import '../../config/supabase_config.dart';
import '../../models/event.dart';
import '../../models/user_profile.dart';
import '../../services/event_service.dart';
import '../../services/category_service.dart';
import '../../services/user_service.dart';
import '../../widgets/featured_event_card.dart';
import '../../widgets/event_list_card.dart';
import '../notifications/notifications_screen.dart';
import '../events/category_events_screen.dart';

// ================================
// HOME SCREEN
// ================================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<EventModel> _featuredEvents = [];
  List<EventModel> _upcomingEvents = [];
  List<String> _categories = [];
  bool _isLoading = true;
  UserProfile? _userProfile;
  
  final _eventService = EventService();
  final _categoryService = CategoryService();
  final _userService = UserService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      // Load user profile
      _userProfile = await _userService.getCurrentUserProfile();

      // Load categories
      _categories = await _categoryService.getCategoryNames();

      // Load featured events
      _featuredEvents = await _eventService.getFeaturedEvents(limit: 5);
      
      // Load upcoming events
      _upcomingEvents = await _eventService.getUpcomingEvents(limit: 10);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, ${_userProfile?.fullName ?? 'User'}! 👋',
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              'Discover amazing events',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const NotificationsScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Categories
                    Text(
                      'Categories',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ActionChip(
                              label: Text(_categories[index]),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => CategoryEventsScreen(
                                      category: _categories[index],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Featured Events
                    Text(
                      'Featured Events',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 280,
                      child: _featuredEvents.isEmpty
                          ? const Center(child: Text('No featured events'))
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _featuredEvents.length,
                              itemBuilder: (context, index) {
                                return FeaturedEventCard(
                                  event: _featuredEvents[index],
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Upcoming Events
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Upcoming Events',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigate to all events
                          },
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _upcomingEvents.isEmpty
                        ? const Center(child: Text('No upcoming events'))
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _upcomingEvents.length,
                            itemBuilder: (context, index) {
                              return EventListCard(
                                event: _upcomingEvents[index],
                              );
                            },
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}

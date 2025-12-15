import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import '../../config/app_theme.dart';
import '../../config/supabase_config.dart';
import '../../models/event.dart';
import '../../models/user_profile.dart';
import '../../services/user_service.dart';
import '../../services/event_service.dart';
import '../../services/registration_service.dart';
import '../tickets/ticket_screen.dart';
import 'organizer_event_details_screen.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _registeredEvents = [];
  List<EventModel> _myCreatedEvents = [];
  bool _isLoading = true;
  UserProfile? _userProfile;
  
  final _userService = UserService();
  final _eventService = EventService();
  final _registrationService = RegistrationService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Load user profile
      _userProfile = await _userService.getUserProfile(userId);

      // Load registered events with event details
      final registrationsData = await supabase
          .from('registrations')
          .select('*, events(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      _registeredEvents = List<Map<String, dynamic>>.from(registrationsData);

      // Load created events if organizer
      if (_userProfile?.role == 'organizer') {
        _myCreatedEvents = await _eventService.getMyEvents();
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Events'),
        bottom: _userProfile?.role == 'organizer'
            ? TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Registered'),
                  Tab(text: 'My Events'),
                ],
              )
            : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userProfile?.role == 'organizer'
              ? TabBarView(
                  controller: _tabController,
                  children: [
                    _buildRegisteredEvents(),
                    _buildMyCreatedEvents(),
                  ],
                )
              : _buildRegisteredEvents(),
    );
  }

  Widget _buildRegisteredEvents() {
    if (_registeredEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.event_busy,
              size: 80,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No registered events',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Start exploring and register for events',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _registeredEvents.length,
        itemBuilder: (context, index) {
          final registration = _registeredEvents[index];
          final event = EventModel.fromJson(registration['events']);
          
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => TicketScreen(
                      eventId: event.id,
                      ticketCode: registration['ticket_code'],
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: event.imageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: event.imageUrl!,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey[300],
                              child: const Icon(Icons.event),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('MMM dd, yyyy').format(event.eventDate),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: registration['checked_in']
                                  ? AppTheme.secondaryColor.withOpacity(0.1)
                                  : Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              registration['checked_in'] ? 'Checked In' : 'Not Checked In',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: registration['checked_in']
                                    ? AppTheme.secondaryColor
                                    : Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.qr_code, color: AppTheme.primaryColor),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMyCreatedEvents() {
    if (_myCreatedEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.event_note,
              size: 80,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No events created',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create your first event',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _myCreatedEvents.length,
        itemBuilder: (context, index) {
          final event = _myCreatedEvents[index];
          
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => OrganizerEventDetailsScreen(event: event),
                  ),
                ).then((_) => _loadData());
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: event.imageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: event.imageUrl!,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey[300],
                              child: const Icon(Icons.event),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('MMM dd, yyyy').format(event.eventDate),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: event.isPublished
                                      ? AppTheme.secondaryColor.withOpacity(0.1)
                                      : Colors.grey.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  event.isPublished ? 'Published' : 'Draft',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: event.isPublished
                                        ? AppTheme.secondaryColor
                                        : AppTheme.textSecondary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${event.totalSeats - event.availableSeats}/${event.totalSeats} registered',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

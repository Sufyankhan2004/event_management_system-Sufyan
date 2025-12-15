// ================================
// ORGANIZER DASHBOARD SCREEN
// ================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/app_theme.dart';
import '../services/auth_service.dart';
import '../services/event_service.dart';
import '../services/registration_service.dart';
import '../models/user_profile.dart';
import '../models/event.dart';

class OrganizerDashboardScreen extends StatefulWidget {
  const OrganizerDashboardScreen({super.key});

  @override
  State<OrganizerDashboardScreen> createState() => _OrganizerDashboardScreenState();
}

class _OrganizerDashboardScreenState extends State<OrganizerDashboardScreen> {
  final _authService = AuthService();
  final _eventService = EventService();
  
  UserProfile? _userProfile;
  List<EventModel> _myEvents = [];
  int _totalAttendees = 0;
  int _totalEvents = 0;
  int _upcomingEvents = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      // Load user profile
      _userProfile = await _authService.getCurrentUserProfile();
      
      if (_userProfile != null) {
        // Load organizer events
        _myEvents = await _eventService.getEventsByOrganizer(_userProfile!.id);
        
        _totalEvents = _myEvents.length;
        _upcomingEvents = _myEvents.where((e) => 
          e.eventDate.isAfter(DateTime.now()) && e.isPublished
        ).length;
        
        // Calculate total attendees
        _totalAttendees = _myEvents.fold(0, (sum, event) => 
          sum + (event.totalSeats - event.availableSeats)
        );
      }

      setState(() => _isLoading = false);
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
              'Hello, ${_userProfile?.fullName ?? 'Organizer'}! 👋',
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              'Organizer Dashboard',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
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
                    // Stats Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total Events',
                            _totalEvents.toString(),
                            Icons.event,
                            AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Upcoming',
                            _upcomingEvents.toString(),
                            Icons.upcoming,
                            AppTheme.secondaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total Attendees',
                            _totalAttendees.toString(),
                            Icons.people,
                            Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Published',
                            _myEvents.where((e) => e.isPublished).length.toString(),
                            Icons.check_circle,
                            Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Recent Events
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Events',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    _myEvents.isEmpty
                        ? Center(
                            child: Column(
                              children: [
                                const SizedBox(height: 40),
                                const Icon(
                                  Icons.event_note,
                                  size: 80,
                                  color: AppTheme.textSecondary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No events yet',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Create your first event to get started',
                                  style: TextStyle(color: AppTheme.textSecondary),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _myEvents.length > 5 ? 5 : _myEvents.length,
                            itemBuilder: (context, index) {
                              final event = _myEvents[index];
                              final attendeeCount = event.totalSeats - event.availableSeats;
                              
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                                    child: const Icon(
                                      Icons.event,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                  title: Text(
                                    event.title,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    '$attendeeCount/${event.totalSeats} registered',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  trailing: Container(
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
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
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
}

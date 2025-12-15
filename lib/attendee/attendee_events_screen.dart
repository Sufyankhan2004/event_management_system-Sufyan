// ================================
// ATTENDEE EVENTS SCREEN
// ================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import '../config/app_theme.dart';
import '../services/auth_service.dart';
import '../services/registration_service.dart';
import '../models/event.dart';
import '../screens/tickets/ticket_screen.dart';

class AttendeeEventsScreen extends StatefulWidget {
  const AttendeeEventsScreen({super.key});

  @override
  State<AttendeeEventsScreen> createState() => _AttendeeEventsScreenState();
}

class _AttendeeEventsScreenState extends State<AttendeeEventsScreen> {
  final _authService = AuthService();
  final _registrationService = RegistrationService();
  
  List<Map<String, dynamic>> _registeredEvents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final userId = _authService.getCurrentUserId();
      if (userId == null) return;

      // Load registered events
      _registeredEvents = await _registrationService.getUserRegistrations(userId);

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
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _registeredEvents.isEmpty
              ? Center(
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
                )
              : RefreshIndicator(
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
                ),
    );
  }
}

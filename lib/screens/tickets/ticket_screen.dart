import 'package:event_semester_sufyan/models/registration.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

import '../../config/app_theme.dart';
import '../../config/supabase_config.dart';
import '../../models/event.dart';

class TicketScreen extends StatefulWidget {
  final String eventId;
  final String ticketCode;
  
  const TicketScreen({
    super.key,
    required this.eventId,
    required this.ticketCode,
  });

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  EventModel? _event;
  RegistrationModel? _registration;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTicketData();
  }

  Future<void> _loadTicketData() async {
    try {
      // Load event
      final eventData = await supabase
          .from('events')
          .select()
          .eq('id', widget.eventId)
          .single();
      
      _event = EventModel.fromJson(eventData);
      
      // Load registration
      final userId = supabase.auth.currentUser?.id;
      final registrationData = await supabase
          .from('registrations')
          .select()
          .eq('event_id', widget.eventId)
          .eq('user_id', userId!)
          .single();
      
      _registration = RegistrationModel.fromJson(registrationData);
      
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ticket')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_event == null || _registration == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ticket')),
        body: const Center(child: Text('Ticket not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Ticket'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share ticket
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Success Message
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppTheme.secondaryColor, AppTheme.secondaryColor.withOpacity(0.7)],
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Registration Successful!',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your ticket has been generated',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            
            // Ticket Card
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Event Title
                      Text(
                        _event!.title,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      
                      // Ticket Code
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Ticket Code: ${_registration!.ticketCode}',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Event Details
                      _buildTicketDetail(
                        Icons.calendar_today,
                        'Date',
                        DateFormat('EEEE, MMMM dd, yyyy').format(_event!.eventDate),
                      ),
                      _buildTicketDetail(
                        Icons.access_time,
                        'Time',
                        DateFormat('hh:mm a').format(_event!.eventDate),
                      ),
                      _buildTicketDetail(
                        Icons.location_on,
                        'Location',
                        '${_event!.venue}, ${_event!.location}',
                      ),
                      _buildTicketDetail(
                        Icons.confirmation_number,
                        'Tickets',
                        '${_registration!.numberOfTickets}',
                      ),
                      _buildTicketDetail(
                        Icons.attach_money,
                        'Total Paid',
                        '\$${_registration!.totalAmount.toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 16),
                      
                      // Check-in Status
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _registration!.checkedIn
                              ? AppTheme.secondaryColor.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _registration!.checkedIn
                                  ? Icons.check_circle
                                  : Icons.pending,
                              color: _registration!.checkedIn
                                  ? AppTheme.secondaryColor
                                  : Colors.orange,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _registration!.checkedIn
                                  ? 'Checked In'
                                  : 'Not Checked In Yet',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: _registration!.checkedIn
                                    ? AppTheme.secondaryColor
                                    : Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Instructions
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Important Instructions',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInstruction('Present this QR code at the event entrance'),
                      _buildInstruction('Arrive at least 15 minutes before the event'),
                      _buildInstruction('Keep your ticket code safe'),
                      _buildInstruction('Take a screenshot for offline access'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketDetail(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.textSecondary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInstruction(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, size: 16, color: AppTheme.secondaryColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

// ================================
// MY EVENTS SCREEN
// ================================


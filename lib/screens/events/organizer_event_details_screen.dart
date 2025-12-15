import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../config/app_theme.dart';
import '../../config/supabase_config.dart';
import '../../models/event.dart';
import '../../services/registration_service.dart';

class OrganizerEventDetailsScreen extends StatefulWidget {
  final EventModel event;
  
  const OrganizerEventDetailsScreen({super.key, required this.event});

  @override
  State<OrganizerEventDetailsScreen> createState() => _OrganizerEventDetailsScreenState();
}

class _OrganizerEventDetailsScreenState extends State<OrganizerEventDetailsScreen> {
  List<Map<String, dynamic>> _registrations = [];
  bool _isLoading = true;
  
  final _registrationService = RegistrationService();

  @override
  void initState() {
    super.initState();
    _loadRegistrations();
  }

  Future<void> _loadRegistrations() async {
    setState(() => _isLoading = true);
    
    try {
      // Load registrations with user details
      final data = await supabase
          .from('registrations')
          .select('*, profiles(full_name, phone)')
          .eq('event_id', widget.event.id)
          .order('created_at', ascending: false);
      
      setState(() {
        _registrations = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final registeredCount = widget.event.totalSeats - widget.event.availableSeats;
    final revenue = _registrations.fold<double>(
      0, 
      (sum, reg) => sum + (reg['total_amount'] as num).toDouble(),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        // ✅ Removed QR scanner button
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Event Info
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.event.title,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          DateFormat('EEEE, MMMM dd, yyyy • hh:mm a')
                              .format(widget.event.eventDate),
                          style: const TextStyle(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Statistics
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Registered',
                        '$registeredCount',
                        Icons.people,
                        AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Available',
                        '${widget.event.availableSeats}',
                        Icons.event_seat,
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
                        'Revenue',
                        '\$${revenue.toStringAsFixed(2)}',
                        Icons.attach_money,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Checked In',
                        '${_registrations.where((r) => r['checked_in']).length}',
                        Icons.check_circle,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Registrations List
                Text(
                  'Registrations',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                
                _registrations.isEmpty
                    ? const Card(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(
                            child: Text('No registrations yet'),
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _registrations.length,
                        itemBuilder: (context, index) {
                          final reg = _registrations[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: reg['checked_in']
                                    ? AppTheme.secondaryColor
                                    : AppTheme.primaryColor,
                                child: Text(
                                  reg['profiles']['full_name'][0].toUpperCase(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(reg['profiles']['full_name']),
                              subtitle: Text(
                                'Tickets: ${reg['number_of_tickets']} • ${reg['ticket_code']}',
                              ),
                              trailing: Icon(
                                reg['checked_in'] 
                                    ? Icons.check_circle 
                                    : Icons.pending,
                                color: reg['checked_in']
                                    ? AppTheme.secondaryColor
                                    : Colors.orange,
                              ),
                            ),
                          );
                        },
                      ),
              ],
            ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
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
}

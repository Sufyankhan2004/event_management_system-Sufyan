import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../config/supabase_config.dart';
import '../../models/event.dart';
import '../tickets/ticket_screen.dart';

class EventRegistrationScreen extends StatefulWidget {
  final EventModel event;
  
  const EventRegistrationScreen({super.key, required this.event});

  @override
  State<EventRegistrationScreen> createState() => _EventRegistrationScreenState();
}

class _EventRegistrationScreenState extends State<EventRegistrationScreen> {
  int _numberOfTickets = 1;
  String _paymentMethod = 'Credit Card';
  bool _isProcessing = false;

  double get _totalAmount => widget.event.ticketPrice * _numberOfTickets;

  Future<void> _processRegistration() async {
    if (_numberOfTickets > widget.event.availableSeats) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough seats available')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Generate unique ticket code
      final ticketCode = const Uuid().v4().substring(0, 8).toUpperCase();
      
      // Create QR code data
      final qrCodeData = jsonEncode({
        'eventId': widget.event.id,
        'userId': userId,
        'ticketCode': ticketCode,
        'numberOfTickets': _numberOfTickets,
      });

      // Create registration
      await supabase.from('registrations').insert({
        'event_id': widget.event.id,
        'user_id': userId,
        'ticket_code': ticketCode,
        'qr_code_data': qrCodeData,
        'number_of_tickets': _numberOfTickets,
        'total_amount': _totalAmount,
        'payment_status': 'completed',
        'payment_method': _paymentMethod,
      });

      // Update available seats
      await supabase
          .from('events')
          .update({
            'available_seats': widget.event.availableSeats - _numberOfTickets,
          })
          .eq('id', widget.event.id);

      // Create notification
      await supabase.from('notifications').insert({
        'user_id': userId,
        'title': 'Registration Successful',
        'message': 'You have successfully registered for ${widget.event.title}',
        'type': 'registration',
        'related_event_id': widget.event.id,
      });

      if (!mounted) return;

      Navigator.of(context).pop();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => TicketScreen(
            eventId: widget.event.id,
            ticketCode: ticketCode,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Registration'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.event.title,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('EEEE, MMMM dd, yyyy • hh:mm a').format(widget.event.eventDate),
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Number of Tickets
            Text(
              'Number of Tickets',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: _numberOfTickets > 1
                          ? () => setState(() => _numberOfTickets--)
                          : null,
                    ),
                    Text(
                      '$_numberOfTickets',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: _numberOfTickets < widget.event.availableSeats
                          ? () => setState(() => _numberOfTickets++)
                          : null,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Payment Method
            if (widget.event.ticketPrice > 0) ...[
              Text(
                'Payment Method',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    RadioListTile<String>(
                      title: const Text('Credit Card'),
                      value: 'Credit Card',
                      groupValue: _paymentMethod,
                      onChanged: (value) {
                        setState(() => _paymentMethod = value!);
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('Debit Card'),
                      value: 'Debit Card',
                      groupValue: _paymentMethod,
                      onChanged: (value) {
                        setState(() => _paymentMethod = value!);
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('PayPal'),
                      value: 'PayPal',
                      groupValue: _paymentMethod,
                      onChanged: (value) {
                        setState(() => _paymentMethod = value!);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            
            // Price Summary
            Card(
              color: AppTheme.primaryColor.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Ticket Price'),
                        Text('\$${widget.event.ticketPrice.toStringAsFixed(2)}'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Quantity'),
                        Text('$_numberOfTickets'),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\$${_totalAmount.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Register Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processRegistration,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        widget.event.ticketPrice == 0 
                            ? 'Confirm Registration' 
                            : 'Complete Payment',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

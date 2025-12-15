import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../config/supabase_config.dart';
import '../../models/event.dart';
import '../../services/registration_service.dart';
import '../../services/ticket_service.dart';
import '../../services/notification_service.dart';
import '../../services/payment_service.dart';
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
  
  final _registrationService = RegistrationService();
  final _ticketService = TicketService();
  final _notificationService = NotificationService();
  final _paymentService = PaymentService();

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

      // Create registration
      final registration = await _registrationService.createRegistration(
        eventId: widget.event.id,
        numberOfTickets: _numberOfTickets,
        totalAmount: _totalAmount,
        paymentStatus: 'completed',
      );

      // Process payment
      await _paymentService.processPayment(
        registrationId: registration.id,
        eventId: widget.event.id,
        amount: _totalAmount,
        paymentMethod: _paymentMethod,
      );

      // Generate tickets
      await _ticketService.generateTickets(
        registrationId: registration.id,
        eventId: widget.event.id,
        numberOfTickets: _numberOfTickets,
        pricePerTicket: widget.event.ticketPrice,
      );

      // Send confirmation notification
      await _notificationService.sendRegistrationConfirmation(
        userId: userId,
        eventId: widget.event.id,
        eventTitle: widget.event.title,
      );

      if (!mounted) return;

      Navigator.of(context).pop();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => TicketScreen(
            eventId: widget.event.id,
            ticketCode: registration.ticketCode,
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

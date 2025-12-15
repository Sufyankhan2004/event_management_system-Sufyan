import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../config/app_theme.dart';
import '../../config/supabase_config.dart';
import '../../models/event.dart';
import '../../services/event_service.dart';
import '../../services/favorite_service.dart';
import '../../services/registration_service.dart';
import 'event_registration_screen.dart';

// ================================
// EVENT DETAILS SCREEN
// ================================


class EventDetailsScreen extends StatefulWidget {
  final String eventId;
  
  const EventDetailsScreen({super.key, required this.eventId});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  EventModel? _event;
  bool _isLoading = true;
  bool _isFavorite = false;
  bool _isRegistered = false;
  List<Map<String, dynamic>> _reviews = [];
  
  final _eventService = EventService();
  final _favoriteService = FavoriteService();
  final _registrationService = RegistrationService();

  @override
  void initState() {
    super.initState();
    _loadEventDetails();
  }

  Future<void> _loadEventDetails() async {
    setState(() => _isLoading = true);
    
    try {
      // Load event
      _event = await _eventService.getEvent(widget.eventId);
      
      if (_event == null) {
        throw Exception('Event not found');
      }
      
      // Check if favorited
      _isFavorite = await _favoriteService.isFavorite(widget.eventId);
      
      // Check if registered
      _isRegistered = await _registrationService.isUserRegistered(widget.eventId);
      
      // Load reviews
      final reviewsData = await supabase
          .from('reviews')
          .select('*, profiles(full_name)')
          .eq('event_id', widget.eventId)
          .order('created_at', ascending: false);
      
      setState(() {
        _reviews = List<Map<String, dynamic>>.from(reviewsData);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading event: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      final newState = await _favoriteService.toggleFavorite(widget.eventId);
      setState(() => _isFavorite = newState);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }
  }

  void _registerForEvent() {
    if (_event == null) return;
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EventRegistrationScreen(event: _event!),
      ),
    ).then((_) => _loadEventDetails());
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    if (_event == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Event not found')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _event!.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: _event!.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported, size: 50),
                      ),
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.event, size: 80),
                      ),
                    ),
            ),
            actions: [
              IconButton(
                icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
                onPressed: _toggleFavorite,
                color: _isFavorite ? Colors.red : null,
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  // Share functionality
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Title
                  Text(
                    _event!.title,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Category Badge
                  Chip(
                    label: Text(_event!.category),
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    labelStyle: const TextStyle(color: AppTheme.primaryColor),
                  ),
                  const SizedBox(height: 16),
                  
                  // Event Details Cards
                  _buildInfoCard(
                    Icons.calendar_today,
                    'Date',
                    DateFormat('EEEE, MMMM dd, yyyy').format(_event!.eventDate),
                  ),
                  _buildInfoCard(
                    Icons.access_time,
                    'Time',
                    DateFormat('hh:mm a').format(_event!.eventDate),
                  ),
                  _buildInfoCard(
                    Icons.location_on,
                    'Location',
                    '${_event!.venue}, ${_event!.location}',
                  ),
                  _buildInfoCard(
                    Icons.confirmation_number,
                    'Available Seats',
                    '${_event!.availableSeats} / ${_event!.totalSeats}',
                  ),
                  _buildInfoCard(
                    Icons.attach_money,
                    'Ticket Price',
                    _event!.ticketPrice == 0 
                        ? 'FREE' 
                        : '\$${_event!.ticketPrice.toStringAsFixed(2)}',
                  ),
                  const SizedBox(height: 24),
                  
                  // Description
                  Text(
                    'About Event',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _event!.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Reviews Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Reviews (${_reviews.length})',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (_isRegistered)
                        TextButton(
                          onPressed: () {
                            _showReviewDialog();
                          },
                          child: const Text('Write Review'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Reviews List
                  _reviews.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              'No reviews yet',
                              style: TextStyle(color: AppTheme.textSecondary),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _reviews.length,
                          itemBuilder: (context, index) {
                            final review = _reviews[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          review['profiles']['full_name'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            const Icon(Icons.star, size: 16, color: Colors.amber),
                                            Text(' ${review['rating']}'),
                                          ],
                                        ),
                                      ],
                                    ),
                                    if (review['comment'] != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        review['comment'],
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _event!.availableSeats > 0 && !_isRegistered
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: _registerForEvent,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    _event!.ticketPrice == 0 
                        ? 'Register Now' 
                        : 'Buy Ticket - \$${_event!.ticketPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            )
          : _isRegistered
              ? SafeArea(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    color: AppTheme.secondaryColor.withOpacity(0.1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle, color: AppTheme.secondaryColor),
                        const SizedBox(width: 8),
                        Text(
                          'Already Registered',
                          style: GoogleFonts.poppins(
                            color: AppTheme.secondaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SafeArea(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.red.withOpacity(0.1),
                    child: const Text(
                      'Event Full',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppTheme.primaryColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReviewDialog() {
    double rating = 5;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Write Review'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RatingBar.builder(
                    initialRating: rating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: false,
                    itemCount: 5,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 4),
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (value) {
                      setDialogState(() => rating = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Comment (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final userId = supabase.auth.currentUser?.id;
                      await supabase.from('reviews').insert({
                        'event_id': widget.eventId,
                        'user_id': userId,
                        'rating': rating.toInt(),
                        'comment': commentController.text.trim().isEmpty 
                            ? null 
                            : commentController.text.trim(),
                      });
                      
                      if (!mounted) return;
                      Navigator.pop(context);
                      _loadEventDetails();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Review submitted!')),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${e.toString()}')),
                      );
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

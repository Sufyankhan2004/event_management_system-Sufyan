// ================================
// ATTENDEE SEARCH SCREEN
// ================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/app_theme.dart';
import '../services/event_service.dart';
import '../models/event.dart';
import '../widgets/event_list_card.dart';

class AttendeeSearchScreen extends StatefulWidget {
  const AttendeeSearchScreen({super.key});

  @override
  State<AttendeeSearchScreen> createState() => _AttendeeSearchScreenState();
}

class _AttendeeSearchScreenState extends State<AttendeeSearchScreen> {
  final _eventService = EventService();
  final _searchController = TextEditingController();
  
  List<EventModel> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _hasSearched = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    
    try {
      final results = await _eventService.searchEvents(query.trim());
      setState(() {
        _searchResults = results;
        _isSearching = false;
        _hasSearched = true;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
        _hasSearched = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search failed: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Events'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search events...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchResults = [];
                            _hasSearched = false;
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  _performSearch(value);
                } else {
                  setState(() {
                    _searchResults = [];
                    _hasSearched = false;
                  });
                }
              },
            ),
          ),
          
          // Results
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : !_hasSearched
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.search,
                              size: 80,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Search for events',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Find events by title, location, or description',
                              style: TextStyle(color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      )
                    : _searchResults.isEmpty
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
                                  'No events found',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Try a different search term',
                                  style: TextStyle(color: AppTheme.textSecondary),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              return EventListCard(
                                event: _searchResults[index],
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

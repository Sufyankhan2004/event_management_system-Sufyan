import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/app_theme.dart';
import '../../config/supabase_config.dart';
import '../../models/event.dart';
import '../../services/event_service.dart';
import '../../services/category_service.dart';
import '../../widgets/event_list_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  List<EventModel> _searchResults = [];
  bool _isSearching = false;
  String? _selectedCategory;
  List<String> _categories = [];
  
  final _eventService = EventService();
  final _categoryService = CategoryService();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      _categories = await _categoryService.getCategoryNames();
      setState(() {});
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _searchEvents() async {
    if (_searchController.text.isEmpty && _selectedCategory == null) return;
    
    setState(() => _isSearching = true);
    
    try {
      List<EventModel> results;
      
      if (_selectedCategory != null && _searchController.text.isEmpty) {
        // Search by category only
        results = await _eventService.getEventsByCategory(_selectedCategory!);
      } else if (_searchController.text.isNotEmpty && _selectedCategory == null) {
        // Search by text only
        results = await _eventService.searchEvents(_searchController.text);
      } else {
        // Search by both text and category
        final allResults = await _eventService.searchEvents(_searchController.text);
        results = allResults.where((e) => e.category == _selectedCategory).toList();
      }
      
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
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
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search events...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchResults = []);
                      },
                    ),
                  ),
                  onSubmitted: (_) => _searchEvents(),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Filter by Category',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Categories'),
                    ),
                    ..._categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedCategory = value);
                    _searchEvents();
                  },
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _searchEvents,
                    child: const Text('Search'),
                  ),
                ),
              ],
            ),
          ),
          
          // Results
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No results found',
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
                        padding: const EdgeInsets.all(16),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          return EventListCard(event: _searchResults[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// ================================
// NOTIFICATIONS SCREEN
// ================================


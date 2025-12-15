import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../config/app_theme.dart';
import '../../config/supabase_config.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _venueController = TextEditingController();
  final _ticketPriceController = TextEditingController();
  final _totalSeatsController = TextEditingController();
  
  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = TimeOfDay.now();
  File? _selectedImage;
  bool _isLoading = false;
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final data = await supabase.from('event_categories').select('name');
    setState(() {
      _categories = data.map((e) => e['name'] as String).toList();
      if (_categories.isNotEmpty) _selectedCategory = _categories.first;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return null;
    
    try {
      final userId = supabase.auth.currentUser!.id;
      final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '$userId/$fileName';
      
      await supabase.storage
          .from('event-images')
          .upload(filePath, _selectedImage!);
      
      final imageUrl = supabase.storage
          .from('event-images')
          .getPublicUrl(filePath);
      
      return imageUrl;
    } catch (e) {
      return null;
    }
  }

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');
      
      // Upload image
      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await _uploadImage();
      }
      
      // Combine date and time
      final eventDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );
      
      // Create event
      final totalSeats = int.parse(_totalSeatsController.text);
      await supabase.from('events').insert({
        'organizer_id': userId,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory,
        'location': _locationController.text.trim(),
        'venue': _venueController.text.trim(),
        'event_date': eventDateTime.toIso8601String(),
        'image_url': imageUrl,
        'ticket_price': double.parse(_ticketPriceController.text.isEmpty 
            ? '0' 
            : _ticketPriceController.text),
        'total_seats': totalSeats,
        'available_seats': totalSeats,
        'is_published': true,
        'status': 'upcoming',
      });
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event created successfully!')),
      );
      
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Image Picker
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  image: _selectedImage != null
                      ? DecorationImage(
                          image: FileImage(_selectedImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _selectedImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate, 
                              size: 50, 
                              color: Colors.grey[400]),
                          const SizedBox(height: 8),
                          Text(
                            'Add Event Image',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            
            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Event Title',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter event title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Description
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description),
                alignLabelWithHint: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Category
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedCategory = value);
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a category';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Location
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'City/Location',
                prefixIcon: Icon(Icons.location_city),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter location';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Venue
            TextFormField(
              controller: _venueController,
              decoration: const InputDecoration(
                labelText: 'Venue',
                prefixIcon: Icon(Icons.place),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter venue';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Date Picker
            ListTile(
              title: const Text('Event Date'),
              subtitle: Text(DateFormat('MMMM dd, yyyy').format(_selectedDate)),
              leading: const Icon(Icons.calendar_today),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() => _selectedDate = date);
                }
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              tileColor: Colors.grey[100],
            ),
            const SizedBox(height: 16),
            
            // Time Picker
            ListTile(
              title: const Text('Event Time'),
              subtitle: Text(_selectedTime.format(context)),
              leading: const Icon(Icons.access_time),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime,
                );
                if (time != null) {
                  setState(() => _selectedTime = time);
                }
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              tileColor: Colors.grey[100],
            ),
            const SizedBox(height: 16),
            
            // Ticket Price
            TextFormField(
              controller: _ticketPriceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Ticket Price (Enter 0 for free)',
                prefixIcon: Icon(Icons.attach_money),
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid price';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Total Seats
            TextFormField(
              controller: _totalSeatsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Total Seats',
                prefixIcon: Icon(Icons.event_seat),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter total seats';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            
            // Create Button
            ElevatedButton(
              onPressed: _isLoading ? null : _createEvent,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Create Event', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

/// ================================
// ORGANIZER EVENT DETAILS SCREEN
// ================================


import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

// ================================
// BASE SERVICE CLASS
// ================================
// Provides common CRUD operations for database tables

class BaseService {
  final String tableName;
  
  BaseService(this.tableName);
  
  // Get Supabase client
  SupabaseClient get client => supabase;
  
  // Get current user ID
  String? get currentUserId => supabase.auth.currentUser?.id;
  
  // Create a new record
  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    try {
      final response = await supabase
          .from(tableName)
          .insert(data)
          .select()
          .single();
      return response;
    } catch (e) {
      throw Exception('Failed to create record in $tableName: ${e.toString()}');
    }
  }
  
  // Get a single record by ID
  Future<Map<String, dynamic>?> getById(String id) async {
    try {
      final response = await supabase
          .from(tableName)
          .select()
          .eq('id', id)
          .maybeSingle();
      return response;
    } catch (e) {
      throw Exception('Failed to get record from $tableName: ${e.toString()}');
    }
  }
  
  // Get all records with optional filters
  Future<List<Map<String, dynamic>>> getAll({
    Map<String, dynamic>? filters,
    String? orderBy,
    bool ascending = true,
    int? limit,
  }) async {
    try {
      dynamic query = supabase.from(tableName).select();
      
      // Apply filters
      if (filters != null) {
        filters.forEach((key, value) {
          query = query.eq(key, value);
        });
      }
      
      // Apply ordering
      if (orderBy != null) {
        query = query.order(orderBy, ascending: ascending);
      }
      
      // Apply limit
      if (limit != null) {
        query = query.limit(limit);
      }
      
      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get records from $tableName: ${e.toString()}');
    }
  }
  
  // Update a record by ID
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> data) async {
    try {
      final response = await supabase
          .from(tableName)
          .update(data)
          .eq('id', id)
          .select()
          .single();
      return response;
    } catch (e) {
      throw Exception('Failed to update record in $tableName: ${e.toString()}');
    }
  }
  
  // Delete a record by ID
  Future<void> delete(String id) async {
    try {
      await supabase
          .from(tableName)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete record from $tableName: ${e.toString()}');
    }
  }
  
  // Custom query with select and filters
  Future<List<Map<String, dynamic>>> query({
    String select = '*',
    Map<String, dynamic>? filters,
    String? orderBy,
    bool ascending = true,
    int? limit,
  }) async {
    try {
      dynamic query = supabase.from(tableName).select(select);
      
      // Apply filters
      if (filters != null) {
        filters.forEach((key, value) {
          query = query.eq(key, value);
        });
      }
      
      // Apply ordering
      if (orderBy != null) {
        query = query.order(orderBy, ascending: ascending);
      }
      
      // Apply limit
      if (limit != null) {
        query = query.limit(limit);
      }
      
      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to query $tableName: ${e.toString()}');
    }
  }
}

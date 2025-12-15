import '../models/category.dart';
import 'base_service.dart';

// ================================
// CATEGORY SERVICE
// ================================
// Handles event category operations

class CategoryService extends BaseService {
  CategoryService() : super('event_categories');
  
  // Get all categories
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final data = await getAll(orderBy: 'name', ascending: true);
      return data.map((json) => CategoryModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get categories: ${e.toString()}');
    }
  }
  
  // Get category by ID
  Future<CategoryModel?> getCategory(String categoryId) async {
    try {
      final data = await getById(categoryId);
      if (data == null) return null;
      return CategoryModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get category: ${e.toString()}');
    }
  }
  
  // Create a new category
  Future<CategoryModel> createCategory(Map<String, dynamic> categoryData) async {
    try {
      final response = await create(categoryData);
      return CategoryModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create category: ${e.toString()}');
    }
  }
  
  // Update category
  Future<CategoryModel> updateCategory(String categoryId, Map<String, dynamic> data) async {
    try {
      final response = await update(categoryId, data);
      return CategoryModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update category: ${e.toString()}');
    }
  }
  
  // Delete category
  Future<void> deleteCategory(String categoryId) async {
    try {
      await delete(categoryId);
    } catch (e) {
      throw Exception('Failed to delete category: ${e.toString()}');
    }
  }
  
  // Get category names only (for dropdowns)
  Future<List<String>> getCategoryNames() async {
    try {
      final categories = await getAllCategories();
      return categories.map((cat) => cat.name).toList();
    } catch (e) {
      throw Exception('Failed to get category names: ${e.toString()}');
    }
  }
}

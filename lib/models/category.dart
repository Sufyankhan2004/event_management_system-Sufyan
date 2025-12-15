// ================================
// CATEGORY MODEL
// ================================

class CategoryModel {
  final String id;
  final String name;
  final String? description;
  final String? iconUrl;
  final DateTime createdAt;
  
  CategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.iconUrl,
    required this.createdAt,
  });
  
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      iconUrl: json['icon_url'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'icon_url': iconUrl,
    };
  }
}

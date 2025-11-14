/// Model representing a food category (updated for new API)
class CategoryModel {
  final int id;
  final String category;
  final String inOl;
  final int kot;
  final String date;
  final int usrid;
  final int categoryindex;

  const CategoryModel({
    required this.id,
    required this.category,
    required this.inOl,
    required this.kot,
    required this.date,
    required this.usrid,
    required this.categoryindex,
  });

  /// Create from JSON
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['Id'] ?? 0,
      category: json['Category'] ?? '',
      inOl: json['InOl'] ?? '',
      kot: json['KOT'] ?? 0,
      date: json['Date'] ?? '',
      usrid: json['Usrid'] ?? 0,
      categoryindex: json['categoryindex'] ?? 0,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Category': category,
      'InOl': inOl,
      'KOT': kot,
      'Date': date,
      'Usrid': usrid,
      'categoryindex': categoryindex,
    };
  }

  /// Create a copy with updated properties
  CategoryModel copyWith({
    int? id,
    String? category,
    String? inOl,
    int? kot,
    String? date,
    int? usrid,
    int? categoryindex,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      category: category ?? this.category,
      inOl: inOl ?? this.inOl,
      kot: kot ?? this.kot,
      date: date ?? this.date,
      usrid: usrid ?? this.usrid,
      categoryindex: categoryindex ?? this.categoryindex,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'CategoryModel(id: $id, category: $category, categoryindex: $categoryindex)';
  }
}

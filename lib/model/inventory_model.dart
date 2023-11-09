class InventoryModel {
  final String id;
  final CategoryModel category;
  final String name;
  final int stock;

  const InventoryModel({
    required this.id,
    required this.category,
    required this.name,
    required this.stock,
  });

  Map<String, dynamic> toMap() {
    return {
      'categoryId': category.id,
      'name': name,
      'stock': stock,
    };
  }
}

class CategoryModel {
  final String id;
  final String name;

  const CategoryModel({
    required this.id,
    required this.name,
  });
}

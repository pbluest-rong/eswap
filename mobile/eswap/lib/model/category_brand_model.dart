class Category {
  final int id;
  final String name;
  final List<Category> children;
  final List<Brand> brands;

  Category({
    required this.id,
    required this.name,
    required this.children,
    required this.brands,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      children: (json['children'] as List<dynamic>?)
          ?.map((e) => Category.fromJson(e))
          .toList() ??
          [],
      brands: (json['brands'] ?? []).map<Brand>((b) => Brand.fromJson(b)).toList(),
    );
  }
}

class Brand {
  final int id;
  final String name;

  Brand({required this.id, required this.name});

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(id: json['id'], name: json['name']);
  }
}

class ItemDetails {
  final int id;
  final String name;
  final String image;
  final int stock;
  final Map<String, dynamic>? category;
  final List<ItemUnit> units;

  ItemDetails({
    required this.id,
    required this.name,
    required this.image,
    required this.stock,
    this.category,
    required this.units,
  });

  factory ItemDetails.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return ItemDetails(
      id: data['id'] as int,
      name: data['name'] as String,
      image: data['image'] as String? ?? '',
      stock: data['stock'] as int? ?? 0,
      category: data['category'] as Map<String, dynamic>?,
      units: (data['units'] as List)
          .map((unit) => ItemUnit.fromJson(unit))
          .toList(),
    );
  }
}

class ItemUnit {
  final int id;
  final String sku;
  final String status;

  ItemUnit({
    required this.id,
    required this.sku,
    required this.status,
  });

  factory ItemUnit.fromJson(Map<String, dynamic> json) => ItemUnit(
    id: json['id'] as int,
    sku: json['sku'] as String,
    status: json['status'] as String,
  );
}
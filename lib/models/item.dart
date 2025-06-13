class Item {
  final int id;
  final String name;
  final String image;
  final int stock;
  final Map<String, dynamic>? category;

  Item({
    required this.id,
    required this.name,
    required this.image,
    required this.stock,
    this.category,
  });

  factory Item.fromJson(Map<String, dynamic> j) => Item(
    id: j['id'] as int,
    name: j['name'] as String,
    image: j['image'] as String? ?? '',
    stock: j['stock'] as int? ?? 0,
    category: j['category'] as Map<String, dynamic>?,
  );
}
class Borrowing {
  final int id;
  final String status;
  final DateTime due;
  final DateTime createdAt;
  final int quantity;
  final Map<String, dynamic>? item;
  final Map<String, dynamic>? user;

  Borrowing({
    required this.id,
    required this.status,
    required this.due,
    required this.createdAt,
    required this.quantity,
    this.item,
    this.user,
  });

  factory Borrowing.fromJson(Map<String, dynamic> json) {
    return Borrowing(
      id: json['id'] as int,
      status: json['status'] as String,
      due: DateTime.parse(json['due'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      quantity: json['quantity'] as int,
      item: json['item'] as Map<String, dynamic>?,
      user: json['user'] as Map<String, dynamic>?,
    );
  }
}
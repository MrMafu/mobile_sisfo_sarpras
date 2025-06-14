class Returning {
  final int id;
  final String status;
  final int returnedQuantity;
  final DateTime createdAt;
  final Map<String, dynamic>? borrowing;
  
  Returning({
    required this.id,
    required this.status,
    required this.returnedQuantity,
    required this.createdAt,
    this.borrowing,
  });

  factory Returning.fromJson(Map<String, dynamic> json) {
    return Returning(
      id: json['id'] as int,
      status: json['status'] as String,
      returnedQuantity: json['returned_quantity'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      borrowing: json['borrowing'] as Map<String, dynamic>?,
    );
  }
}
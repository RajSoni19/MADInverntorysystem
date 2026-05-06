import '../../core/utils/stock_status.dart';

class Product {
  final int? id;
  final String name;
  final String category;
  final int quantity;
  final int minThreshold;
  final DateTime updatedAt;

  const Product({
    this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.minThreshold,
    required this.updatedAt,
  });

  StockStatus get status =>
      getStockStatus(quantity: quantity, threshold: minThreshold);

  Product copyWith({
    int? id,
    String? name,
    String? category,
    int? quantity,
    int? minThreshold,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      minThreshold: minThreshold ?? this.minThreshold,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'category': category,
        'quantity': quantity,
        'min_threshold': minThreshold,
        'updated_at': updatedAt.toIso8601String(),
      };

  factory Product.fromMap(Map<String, Object?> map) {
    return Product(
      id: map['id'] as int?,
      name: map['name'] as String,
      category: map['category'] as String,
      quantity: map['quantity'] as int,
      minThreshold: map['min_threshold'] as int,
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}

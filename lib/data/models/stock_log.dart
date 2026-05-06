enum StockAction { inAction, outAction }

class StockLog {
  final int? id;
  final int productId;
  final String productName;
  final StockAction action;
  final int quantityChanged;
  final int quantityAfter;
  final DateTime createdAt;

  const StockLog({
    this.id,
    required this.productId,
    required this.productName,
    required this.action,
    required this.quantityChanged,
    required this.quantityAfter,
    required this.createdAt,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'product_id': productId,
        'product_name': productName,
        'action': action.name,
        'quantity_changed': quantityChanged,
        'quantity_after': quantityAfter,
        'created_at': createdAt.toIso8601String(),
      };

  factory StockLog.fromMap(Map<String, Object?> map) {
    return StockLog(
      id: map['id'] as int?,
      productId: map['product_id'] as int,
      productName: map['product_name'] as String,
      action: (map['action'] as String) == StockAction.inAction.name
          ? StockAction.inAction
          : StockAction.outAction,
      quantityChanged: map['quantity_changed'] as int,
      quantityAfter: map['quantity_after'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

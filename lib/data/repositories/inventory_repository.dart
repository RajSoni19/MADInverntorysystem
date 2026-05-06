import 'dart:convert';
import 'package:hive/hive.dart';
import '../database/hive_service.dart';
import '../models/pending_sync.dart';
import '../models/product.dart';
import '../models/stock_log.dart';

class InventoryRepository {
  Box<Map> get _products => Hive.box<Map>(HiveService.productsBox);
  Box<Map> get _logs => Hive.box<Map>(HiveService.logsBox);
  Box<Map> get _pending => Hive.box<Map>(HiveService.pendingBox);
  Box get _meta => Hive.box(HiveService.metaBox);

  int _nextId(String key) {
    final current = (_meta.get(key) as int?) ?? 0;
    final next = current + 1;
    _meta.put(key, next);
    return next;
  }

  Future<List<Product>> getProducts() async {
    final items = _products.values
        .map((e) => Product.fromMap(Map<String, Object?>.from(e)))
        .toList();
    items.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return items;
  }

  Future<int> addProduct(Product product) async {
    final id = _nextId('product_id');
    final created = product.copyWith(id: id);
    _products.put(id.toString(), created.toMap().cast<String, dynamic>());
    await queueSync(
      operation: 'add_product',
      payload: jsonEncode(created.toMap()),
    );
    return id;
  }

  Future<void> updateProduct(Product product) async {
    if (product.id == null) return;
    _products.put(
      product.id.toString(),
      product.toMap().cast<String, dynamic>(),
    );
    await queueSync(
      operation: 'update_product',
      payload: jsonEncode(product.toMap()),
    );
  }

  Future<void> deleteProduct(int id) async {
    _products.delete(id.toString());
    await queueSync(
      operation: 'delete_product',
      payload: jsonEncode({'id': id}),
    );
  }

  Future<void> performStockUpdate({
    required Product product,
    required StockAction action,
    required int amount,
  }) async {
    if (product.id == null) return;
    final stored = _products.get(product.id.toString());
    if (stored == null) return;
    final current = Product.fromMap(Map<String, Object?>.from(stored));
    final updatedQty = action == StockAction.inAction
        ? current.quantity + amount
        : current.quantity - amount;
    if (updatedQty < 0) {
      throw Exception('Cannot reduce stock below zero.');
    }
    final updatedProduct = current.copyWith(
      quantity: updatedQty,
      updatedAt: DateTime.now(),
    );
    _products.put(
      updatedProduct.id.toString(),
      updatedProduct.toMap().cast<String, dynamic>(),
    );
    final log = StockLog(
      id: _nextId('log_id'),
      productId: updatedProduct.id!,
      productName: updatedProduct.name,
      action: action,
      quantityChanged: amount,
      quantityAfter: updatedQty,
      createdAt: DateTime.now(),
    );
    _logs.put(log.id.toString(), log.toMap().cast<String, dynamic>());
    await queueSync(
      operation: 'stock_update',
      payload: jsonEncode({
        'product_id': updatedProduct.id,
        'action': action.name,
        'amount': amount,
      }),
    );
  }

  Future<List<StockLog>> getStockLogs() async {
    final items = _logs.values
        .map((e) => StockLog.fromMap(Map<String, Object?>.from(e)))
        .toList();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  Future<void> queueSync({
    required String operation,
    required String payload,
  }) async {
    final sync = PendingSync(
      id: _nextId('pending_id'),
      operation: operation,
      payload: payload,
      createdAt: DateTime.now(),
    );
    _pending.put(sync.id.toString(), sync.toMap().cast<String, dynamic>());
  }

  Future<int> getPendingSyncCount() async {
    return _pending.length;
  }

  Future<void> syncPending() async {
    await _pending.clear();
  }
}

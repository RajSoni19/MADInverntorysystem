import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../core/utils/stock_status.dart';
import '../data/models/product.dart';
import '../data/models/stock_log.dart';
import '../data/repositories/inventory_repository.dart';

class InventoryProvider extends ChangeNotifier {
  final InventoryRepository _repo = InventoryRepository();
  final Connectivity _connectivity = Connectivity();

  List<Product> _products = [];
  List<StockLog> _logs = [];
  bool _loading = false;
  bool _online = true;
  int _pendingSync = 0;
  String _query = '';
  String? _errorMessage;
  ThemeMode _themeMode = ThemeMode.light;
  String? _selectedCategory;
  StockStatus? _selectedStatus;

  List<Product> get products => _products;
  List<StockLog> get logs => _logs;
  bool get loading => _loading;
  bool get online => _online;
  int get pendingSync => _pendingSync;
  String? get selectedCategory => _selectedCategory;
  StockStatus? get selectedStatus => _selectedStatus;
  String? get errorMessage => _errorMessage;
  ThemeMode get themeMode => _themeMode;
  List<Product> get recentlyUpdated => [..._products]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  List<Product> get filteredProducts {
    return _products.where((p) {
      final queryMatch = _query.isEmpty || p.name.toLowerCase().contains(_query.toLowerCase());
      final categoryMatch = _selectedCategory == null || p.category == _selectedCategory;
      final statusMatch = _selectedStatus == null || p.status == _selectedStatus;
      return queryMatch && categoryMatch && statusMatch;
    }).toList();
  }

  List<String> get categories => _products.map((e) => e.category).toSet().toList()..sort();

  List<Product> get lowStockProducts => _products
      .where((p) => p.status == StockStatus.low || p.status == StockStatus.critical || p.status == StockStatus.outOfStock)
      .toList();

  Map<int, int> get autoReorderPlan {
    final plan = <int, int>{};
    for (final p in lowStockProducts) {
      if (p.id == null) continue;
      final buffer = (p.minThreshold * 1.5).ceil();
      final target = p.minThreshold + buffer;
      final needed = target - p.quantity;
      if (needed > 0) {
        plan[p.id!] = needed;
      }
    }
    return plan;
  }

  Future<void> initialize() async {
    await refresh();
    final initialStatus = await _connectivity.checkConnectivity();
    _online = !initialStatus.contains(ConnectivityResult.none);
    _connectivity.onConnectivityChanged.listen((result) async {
      _online = !result.contains(ConnectivityResult.none);
      notifyListeners();
      if (_online) await syncNow();
    });
  }

  Future<void> refresh() async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _products = await _repo.getProducts();
      _logs = await _repo.getStockLogs();
      _pendingSync = await _repo.getPendingSyncCount();
    } catch (e) {
      _errorMessage = 'Failed to load inventory data. ${e.toString()}';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> addProduct({required String name, required String category, required int quantity, required int minThreshold}) async {
    await _repo.addProduct(
      Product(name: name.trim(), category: category.trim(), quantity: quantity, minThreshold: minThreshold, updatedAt: DateTime.now()),
    );
    await refresh();
  }

  Future<void> updateProduct(Product product) async {
    await _repo.updateProduct(product.copyWith(updatedAt: DateTime.now()));
    await refresh();
  }

  Future<void> deleteProduct(int id) async {
    await _repo.deleteProduct(id);
    await refresh();
  }

  Future<void> updateStock({required Product product, required StockAction action, required int quantity}) async {
    await _repo.performStockUpdate(product: product, action: action, amount: quantity);
    await refresh();
  }

  Future<void> syncNow() async {
    await _repo.syncPending();
    await refresh();
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  void setCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setStatus(StockStatus? status) {
    _selectedStatus = status;
    notifyListeners();
  }

  void clearFilters() {
    _query = '';
    _selectedCategory = null;
    _selectedStatus = null;
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}

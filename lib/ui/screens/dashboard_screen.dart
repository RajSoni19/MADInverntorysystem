import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/stock_status.dart';
import '../../providers/inventory_provider.dart';
import '../widgets/status_chip.dart';
import 'product_management_screen.dart';
import 'search_filter_screen.dart';
import 'stock_history_screen.dart';
import 'stock_update_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _index = 0;
  @override
  Widget build(BuildContext context) {
    final pages = const [
      _DashboardHome(),
      ProductManagementScreen(),
      StockUpdateScreen(),
      StockHistoryScreen(),
      SearchFilterScreen(),
    ];
    return Scaffold(
      body: pages[_index],
      floatingActionButton: _index == 0
          ? FloatingActionButton.extended(
              onPressed: () => _openQuickActions(context),
              backgroundColor: AppTheme.primary,
              icon: const Icon(Icons.bolt),
              label: const Text('Quick Actions'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), label: 'Products'),
          NavigationDestination(icon: Icon(Icons.swap_horiz), label: 'Stock'),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
        ],
      ),
    );
  }

  void _openQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: Icon(Icons.inventory_2), title: Text('Add new product from Products tab')),
            ListTile(leading: Icon(Icons.swap_horiz), title: Text('Update stock from Stock tab')),
            ListTile(leading: Icon(Icons.search), title: Text('Find items quickly in Search tab')),
          ],
        ),
      ),
    );
  }
}

class _DashboardHome extends StatelessWidget {
  const _DashboardHome();
  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryProvider>(builder: (_, vm, __) {
      if (vm.loading) {
        return const Center(child: CircularProgressIndicator());
      }
      if (vm.errorMessage != null) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 40),
                const SizedBox(height: 10),
                Text(
                  vm.errorMessage!,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: vm.refresh,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }
      final recent = vm.recentlyUpdated.take(5).toList();
      final outOfStock = vm.products.where((p) => p.status == StockStatus.outOfStock).length;
      final total = vm.products.length == 0 ? 1 : vm.products.length;
      final available = vm.products.where((p) => p.status == StockStatus.available).length / total;
      final low = vm.products.where((p) => p.status == StockStatus.low || p.status == StockStatus.critical).length / total;
      final out = outOfStock / total;
      return SafeArea(
        child: RefreshIndicator(
          onRefresh: vm.refresh,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF2743FD), Color(0xFF4D63FF)]),
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Smart Inventory',
                            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Consumer<InventoryProvider>(
                          builder: (_, provider, __) => IconButton(
                            onPressed: provider.toggleTheme,
                            icon: Icon(
                              provider.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      vm.online ? 'Online and synchronized' : 'Offline mode active',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _miniMetric('Products', '${vm.products.length}'),
                        _miniMetric('Low', '${vm.lowStockProducts.length}'),
                        _miniMetric('Out', '$outOfStock'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                vm.pendingSync > 0 ? '${vm.pendingSync} updates pending sync' : 'All changes are synchronized',
                style: const TextStyle(color: Color(0xFF616A7D)),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _metricCard('Products', '${vm.products.length}', const Color(0xFF1E88E5))),
                  const SizedBox(width: 10),
                  Expanded(child: _metricCard('Low Stock', '${vm.lowStockProducts.length}', const Color(0xFFF57C00))),
                ],
              ),
              const SizedBox(height: 8),
              _metricCard(
                'Reorder Suggestions',
                '${vm.autoReorderPlan.length}',
                const Color(0xFF8E24AA),
                fullWidth: true,
              ),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Inventory Overview', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _ringSegment('Available', Colors.green, available),
                          _ringSegment('Low', Colors.orange, low),
                          _ringSegment('Out', Colors.red, out),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Low Stock Alerts', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      const SizedBox(height: 6),
                      if (vm.lowStockProducts.isEmpty)
                        const Text('No low stock items.'),
                      ...vm.lowStockProducts.map((p) {
                        final suggested = vm.autoReorderPlan[p.id] ?? 0;
                        return ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(p.name),
                          subtitle: Text(
                            'Qty ${p.quantity} / Min ${p.minThreshold}'
                            '${suggested > 0 ? ' • Reorder +$suggested' : ''}',
                          ),
                          trailing: StatusChip(status: p.status),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Recently Updated', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 8),
              ...recent.map((p) => Card(
                    child: ListTile(
                      title: Text(p.name),
                      subtitle: Text('${p.category} • Qty ${p.quantity}'),
                      trailing: StatusChip(status: p.status),
                    ),
                  )),
            ],
          ),
        ),
      );
    });
  }

  Widget _miniMetric(String title, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.white70)),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
      ),
    );
  }

  Widget _ringSegment(String label, Color color, double value) {
    return Expanded(
      child: Column(
        children: [
          SizedBox(
            height: 62,
            width: 62,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: value.clamp(0.0, 1.0),
                  strokeWidth: 8,
                  backgroundColor: color.withOpacity(0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
                Center(
                  child: Text(
                    '${(value * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(label),
        ],
      ),
    );
  }

  Widget _metricCard(
    String title,
    String value,
    Color color, {
    bool fullWidth = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.22), color.withOpacity(0.12)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

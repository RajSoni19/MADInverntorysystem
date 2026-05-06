import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/inventory_provider.dart';
import '../../data/models/stock_log.dart';

class StockHistoryScreen extends StatefulWidget {
  const StockHistoryScreen({super.key});

  @override
  State<StockHistoryScreen> createState() => _StockHistoryScreenState();
}

class _StockHistoryScreenState extends State<StockHistoryScreen> {
  StockAction? _filter;

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryProvider>(builder: (_, vm, __) {
      final logs = _filter == null ? vm.logs : vm.logs.where((e) => e.action == _filter).toList();
      return Scaffold(
        appBar: AppBar(title: const Text('Stock History')),
        body: logs.isEmpty
            ? const Center(child: Text('No stock movement history yet.'))
            : ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: logs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final l = logs[i];
                  final isIn = l.action == StockAction.inAction;
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: (isIn ? Colors.green : Colors.orange).withOpacity(0.16),
                        child: Icon(isIn ? Icons.add : Icons.remove, color: isIn ? Colors.green : Colors.deepOrange),
                      ),
                      title: Text(l.productName),
                      subtitle: Text(DateFormat('dd MMM yyyy, hh:mm a').format(l.createdAt)),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${isIn ? '+' : '-'}${l.quantityChanged}',
                            style: TextStyle(color: isIn ? Colors.green : Colors.deepOrange, fontWeight: FontWeight.bold),
                          ),
                          Text('After: ${l.quantityAfter}'),
                        ],
                      ),
                    ),
                  );
                },
              ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(8),
          child: Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: _filter == null,
                onSelected: (_) => setState(() => _filter = null),
              ),
              ChoiceChip(
                label: const Text('Stock In'),
                selected: _filter == StockAction.inAction,
                onSelected: (_) => setState(() => _filter = StockAction.inAction),
              ),
              ChoiceChip(
                label: const Text('Stock Out'),
                selected: _filter == StockAction.outAction,
                onSelected: (_) => setState(() => _filter = StockAction.outAction),
              ),
            ],
          ),
        ),
      );
    });
  }
}

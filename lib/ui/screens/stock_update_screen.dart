import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/product.dart';
import '../../data/models/stock_log.dart';
import '../../providers/inventory_provider.dart';
import '../widgets/status_chip.dart';

class StockUpdateScreen extends StatefulWidget {
  const StockUpdateScreen({super.key});

  @override
  State<StockUpdateScreen> createState() => _StockUpdateScreenState();
}

class _StockUpdateScreenState extends State<StockUpdateScreen> {
  int _qty = 1;
  StockAction _action = StockAction.inAction;

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryProvider>(builder: (_, vm, __) {
      return Scaffold(
        appBar: AppBar(title: const Text('Stock Update')),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: SegmentedButton<StockAction>(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith(
                    (states) => states.contains(MaterialState.selected)
                        ? (_action == StockAction.inAction ? Colors.green.withOpacity(0.15) : Colors.deepOrange.withOpacity(0.15))
                        : null,
                  ),
                ),
                segments: const [
                  ButtonSegment(value: StockAction.inAction, label: Text('Stock In'), icon: Icon(Icons.add_circle_outline)),
                  ButtonSegment(value: StockAction.outAction, label: Text('Stock Out'), icon: Icon(Icons.remove_circle_outline)),
                ],
                selected: {_action},
                onSelectionChanged: (value) => setState(() => _action = value.first),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Quantity selector', style: TextStyle(fontWeight: FontWeight.w700)),
                      Row(
                        children: [
                          IconButton(
                            onPressed: _qty > 1 ? () => setState(() => _qty--) : null,
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            child: Text(
                              '$_qty',
                              key: ValueKey(_qty),
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            onPressed: () => setState(() => _qty++),
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: vm.products.isEmpty
            ? const Center(child: Text('No products available for stock updates.'))
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
                itemCount: vm.products.length,
                itemBuilder: (_, i) {
                  final p = vm.products[i];
                  return Card(
                    child: ListTile(
                      title: Text(p.name),
                      subtitle: Text('Current Qty: ${p.quantity}'),
                      leading: StatusChip(status: p.status),
                      trailing: FilledButton(
                        onPressed: () => _update(context, vm, p),
                        style: FilledButton.styleFrom(
                          backgroundColor: _action == StockAction.inAction ? Colors.green : Colors.deepOrange,
                        ),
                        child: Text(_action == StockAction.inAction ? 'Apply In' : 'Apply Out'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _update(BuildContext context, InventoryProvider vm, Product p) async {
    try {
      await vm.updateStock(product: p, action: _action, quantity: _qty);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_action == StockAction.inAction ? 'Added' : 'Deducted'} $_qty units for ${p.name}'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }
}

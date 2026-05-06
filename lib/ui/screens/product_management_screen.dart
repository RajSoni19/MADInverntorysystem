import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/inventory_provider.dart';
import '../../data/models/product.dart';
import '../widgets/product_form_dialog.dart';
import '../widgets/status_chip.dart';

class ProductManagementScreen extends StatelessWidget {
  const ProductManagementScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryProvider>(builder: (_, vm, __) {
      return Scaffold(
        appBar: AppBar(title: const Text('Product Management')),
        body: vm.products.isEmpty
            ? const Center(child: Text('No products added yet.\nTap + to create one.', textAlign: TextAlign.center))
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: vm.products.length,
                itemBuilder: (_, i) {
                  final p = vm.products[i];
                  return Dismissible(
                    key: ValueKey('product-${p.id}'),
                    background: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.edit, color: Colors.red),
                    ),
                    secondaryBackground: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.red),
                    ),
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.startToEnd) {
                        await _openForm(context, vm, initial: p);
                        return false;
                      }
                      return await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Delete Product'),
                              content: Text('Delete "${p.name}" from inventory?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                              ],
                            ),
                          ) ??
                          false;
                    },
                    onDismissed: (_) => vm.deleteProduct(p.id!),
                    child: Card(
                      child: ListTile(
                        title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text('Category: ${p.category}\nQuantity: ${p.quantity} • Min: ${p.minThreshold}'),
                        isThreeLine: true,
                        trailing: const Icon(Icons.swipe),
                        leading: StatusChip(status: p.status),
                        onTap: () => _openForm(context, vm, initial: p),
                      ),
                    ),
                  );
                },
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _openForm(context, vm),
          child: const Icon(Icons.add),
        ),
      );
    });
  }

  Future<void> _openForm(BuildContext context, InventoryProvider vm, {Product? initial}) async {
    final data = await showDialog<Map<String, dynamic>>(context: context, builder: (_) => ProductFormDialog(initial: initial));
    if (data == null) return;
    if (initial == null) {
      await vm.addProduct(
        name: data['name'] as String,
        category: data['category'] as String,
        quantity: data['quantity'] as int,
        minThreshold: data['threshold'] as int,
      );
    } else {
      await vm.updateProduct(initial.copyWith(
        name: data['name'] as String,
        category: data['category'] as String,
        quantity: data['quantity'] as int,
        minThreshold: data['threshold'] as int,
      ));
    }
  }
}

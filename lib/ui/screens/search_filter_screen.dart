import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/stock_status.dart';
import '../../providers/inventory_provider.dart';
import '../widgets/status_chip.dart';

class SearchFilterScreen extends StatefulWidget {
  const SearchFilterScreen({super.key});

  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryProvider>(builder: (_, vm, __) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Search & Filter'),
          actions: [
            TextButton(
              onPressed: vm.clearFilters,
              child: const Text('Clear'),
            ),
          ],
        ),
        body: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: EdgeInsets.fromLTRB(12, _focused ? 8 : 14, 12, 8),
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _focused
                      ? [const Color(0xFF5B72FF), const Color(0xFF93A2FF)]
                      : [Colors.transparent, Colors.transparent],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                onChanged: vm.setQuery,
                onTap: () => setState(() => _focused = true),
                onTapOutside: (_) => setState(() => _focused = false),
                decoration: InputDecoration(
                  hintText: 'Search by product name',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _focused
                      ? IconButton(
                          onPressed: () {
                            vm.setQuery('');
                            setState(() => _focused = false);
                          },
                          icon: const Icon(Icons.close),
                        )
                      : null,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('All'),
                    selected: vm.selectedStatus == null,
                    onSelected: (_) => vm.setStatus(null),
                  ),
                  ChoiceChip(
                    label: const Text('Available'),
                    selected: vm.selectedStatus == StockStatus.available,
                    onSelected: (_) => vm.setStatus(StockStatus.available),
                  ),
                  ChoiceChip(
                    label: const Text('Low Stock'),
                    selected: vm.selectedStatus == StockStatus.low || vm.selectedStatus == StockStatus.critical,
                    onSelected: (_) => vm.setStatus(StockStatus.low),
                  ),
                  ChoiceChip(
                    label: const Text('Out of Stock'),
                    selected: vm.selectedStatus == StockStatus.outOfStock,
                    onSelected: (_) => vm.setStatus(StockStatus.outOfStock),
                  ),
                  DropdownButton<String?>(
                    hint: const Text('Category'),
                    value: vm.selectedCategory,
                    items: [
                      const DropdownMenuItem<String?>(value: null, child: Text('All Categories')),
                      ...vm.categories.map((c) => DropdownMenuItem(value: c, child: Text(c))),
                    ],
                    onChanged: vm.setCategory,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: vm.filteredProducts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.search_off_rounded, size: 54, color: Colors.grey),
                          SizedBox(height: 10),
                          Text('No products found', style: TextStyle(fontWeight: FontWeight.w700)),
                          Text('Try changing filters or search query'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: vm.filteredProducts.length,
                      itemBuilder: (_, i) {
                        final p = vm.filteredProducts[i];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          child: ListTile(
                            title: Text(p.name),
                            subtitle: Text('${p.category} • Qty ${p.quantity}'),
                            trailing: StatusChip(status: p.status),
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
}

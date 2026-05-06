import 'package:flutter/material.dart';
import '../../data/models/product.dart';

class ProductFormDialog extends StatefulWidget {
  final Product? initial;
  const ProductFormDialog({super.key, this.initial});

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _categoryController;
  late final TextEditingController _quantityController;
  late final TextEditingController _thresholdController;

  final List<String> _categories = const [
    'Electronics',
    'Medical',
    'Stationery',
    'Chemicals',
    'Food',
    'Office',
  ];
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initial?.name ?? '');
    _categoryController = TextEditingController(text: widget.initial?.category ?? '');
    _selectedCategory = widget.initial?.category;
    _quantityController = TextEditingController(text: '${widget.initial?.quantity ?? 0}');
    _thresholdController = TextEditingController(text: '${widget.initial?.minThreshold ?? 5}');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _quantityController.dispose();
    _thresholdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? 'Add Product' : 'Edit Product'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              height: 74,
              width: 74,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(colors: [Color(0xFF425CFF), Color(0xFF7588FF)]),
              ),
              child: const Icon(Icons.inventory_2_rounded, color: Colors.white, size: 36),
            ),
            const SizedBox(height: 14),
            _field(_nameController, 'Product Name'),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (value) {
                _selectedCategory = value;
                _categoryController.text = value ?? '';
              },
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Select category' : null,
            ),
            const SizedBox(height: 10),
            _field(_quantityController, 'Quantity', numeric: true),
            _field(
              _thresholdController,
              'Minimum Threshold',
              numeric: true,
            ),
          ]),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                'name': _nameController.text.trim(),
                'category': (_selectedCategory ?? _categoryController.text).trim(),
                'quantity': int.parse(_quantityController.text),
                'threshold': int.parse(_thresholdController.text),
              });
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _field(
    TextEditingController c,
    String hint, {
    bool numeric = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: c,
        keyboardType: numeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: hint,
          prefixIcon: Icon(
            hint == 'Product Name'
                ? Icons.inventory
                : hint == 'Quantity'
                    ? Icons.numbers
                    : Icons.warning_amber_rounded,
          ),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) return 'Required field';
          if (numeric && ((int.tryParse(value) ?? -1) < 0)) {
            return 'Enter valid number';
          }
          if (hint == 'Minimum Threshold' && (int.tryParse(value) ?? 0) == 0) {
            return 'Threshold should be at least 1';
          }
          return null;
        },
      ),
    );
  }
}

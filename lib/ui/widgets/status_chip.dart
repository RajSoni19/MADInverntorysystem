import 'package:flutter/material.dart';
import '../../core/utils/stock_status.dart';

class StatusChip extends StatelessWidget {
  final StockStatus status;
  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    late final Color color;
    late final String label;
    switch (status) {
      case StockStatus.available:
        color = Colors.green;
        label = 'Normal';
        break;
      case StockStatus.low:
        color = Colors.orange;
        label = 'Low';
        break;
      case StockStatus.critical:
        color = Colors.deepOrange;
        label = 'Critical';
        break;
      case StockStatus.outOfStock:
        color = Colors.red;
        label = 'Out of Stock';
        break;
    }
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
      side: BorderSide(color: color.withOpacity(0.4)),
      backgroundColor: color.withOpacity(0.1),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

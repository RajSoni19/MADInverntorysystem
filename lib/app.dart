import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/inventory_provider.dart';
import 'ui/screens/dashboard_screen.dart';

class SmartInventoryApp extends StatelessWidget {
  const SmartInventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryProvider>(
      builder: (_, vm, __) => MaterialApp(
        title: 'Smart Inventory',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: vm.themeMode,
        home: const DashboardScreen(),
      ),
    );
  }
}

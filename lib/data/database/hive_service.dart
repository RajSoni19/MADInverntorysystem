import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  HiveService._();
  static const String productsBox = 'products_box';
  static const String logsBox = 'logs_box';
  static const String pendingBox = 'pending_box';
  static const String metaBox = 'meta_box';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<Map>(productsBox);
    await Hive.openBox<Map>(logsBox);
    await Hive.openBox<Map>(pendingBox);
    await Hive.openBox(metaBox);
  }
}

# Smart Inventory & Stock Replenishment App

Offline-first Flutter application for small retail stores, labs, and campus facilities to manage inventory, track stock movements, and get low-stock alerts.

## Implemented Modules

- Product Management (Add/Edit/Delete with validation)
- Stock Update (Stock In / Stock Out with negative-stock protection)
- Low Stock Alert System (normal/low/critical/out-of-stock indicators)
- Inventory Dashboard (total products, low stock count, recently updated items)
- Stock History & Logs (timestamped movement records)
- Search & Filter (name search, category filter, stock status filter)
- Offline-first operations (local Hive storage + pending sync queue + auto sync trigger on connectivity changes)

## Tech Stack

- Flutter (Material 3)
- Provider (state management)
- Hive + hive_flutter (local storage)
- connectivity_plus (online/offline detection)
- intl (date formatting)

## Screens

1. Inventory Dashboard Screen
2. Product Management Screen
3. Stock Update Screen
4. Stock History Screen
5. Search & Filter Screen

## Inventory Logic

- **Stock status rules**
  - `Out of Stock`: quantity <= 0
  - `Critical`: quantity <= floor(minThreshold / 2)
  - `Low`: quantity <= minThreshold
  - `Normal`: quantity > minThreshold
- **Validation rules**
  - Empty product/category not allowed
  - Quantity and threshold must be valid non-negative integers
  - Threshold must be at least 1
  - Stock-out cannot reduce quantity below zero

## Offline-First + Sync

- All product and stock operations are stored locally in Hive and work offline.
- A pending sync queue is maintained for operations performed offline.
- When connectivity is restored, queue processing is triggered automatically.
- Optional backend integration (Firebase/REST) can be plugged into repository sync flow.

## Run

```bash
flutter pub get
flutter run
```

## Required 4 Commit Plan

1. Project Initialization
2. UI Development
3. Core Logic (Inventory + Stock Updates)
4. Offline Storage & Final Integration

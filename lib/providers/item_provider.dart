import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/item.dart';
import '../repositories/item_repository.dart';

final itemRepositoryProvider = Provider((ref) => ItemRepository());

final itemsProvider = FutureProvider<List<AppItem>>((ref) async {
  final repo = ref.watch(itemRepositoryProvider);
  return repo.getItems();
});

final dashboardStatsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final items = await ref.watch(itemsProvider.future);

  int totalStock = 0;
  int lowStockCount = 0;

  for (var item in items) {
    totalStock += item.stock;
    if (item.stock < 5) {
      lowStockCount++;
    }
  }

  return {
    'totalItems': items.length,
    'totalStock': totalStock,
    'lowStockCount': lowStockCount,
  };
});

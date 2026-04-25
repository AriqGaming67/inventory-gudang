import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/stock_movement.dart';
import '../repositories/stock_repository.dart';
import 'item_provider.dart';

final stockRepositoryProvider = Provider<StockRepository>((ref) {
  return StockRepository();
});

final stockMovementsProvider = FutureProvider.autoDispose
    .family<List<StockMovement>, String?>((ref, itemId) async {
      final repository = ref.read(stockRepositoryProvider);
      return await repository.getStockMovements(itemId: itemId);
    });

class StockLoadingNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setLoading(bool val) {
    state = val;
  }
}

final stockLoadingProvider = NotifierProvider<StockLoadingNotifier, bool>(
  StockLoadingNotifier.new,
);

class StockService {
  final Ref ref;

  StockService(this.ref);

  Future<void> createStockMovement(Map<String, dynamic> data) async {
    ref.read(stockLoadingProvider.notifier).setLoading(true);
    try {
      final repository = ref.read(stockRepositoryProvider);
      await repository.createStockMovement(data);
      ref.invalidate(stockMovementsProvider);
      ref.invalidate(itemsProvider);
      if (data['item_id'] != null) {
        ref.invalidate(itemDetailProvider);
      }
    } finally {
      ref.read(stockLoadingProvider.notifier).setLoading(false);
    }
  }

  Future<void> deleteStockMovement(String id) async {
    ref.read(stockLoadingProvider.notifier).setLoading(true);
    try {
      final repository = ref.read(stockRepositoryProvider);
      await repository.deleteStockMovement(id);
      ref.invalidate(stockMovementsProvider);
    } finally {
      ref.read(stockLoadingProvider.notifier).setLoading(false);
    }
  }
}

final stockServiceProvider = Provider<StockService>((ref) {
  return StockService(ref);
});

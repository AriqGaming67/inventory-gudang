import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/item.dart';
import '../repositories/item_repository.dart';

final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  return ItemRepository();
});

final itemsProvider = FutureProvider.autoDispose<List<Item>>((ref) async {
  final repository = ref.read(itemRepositoryProvider);
  return await repository.getItems();
});

enum StockFilter { all, outOfStock, lowStock, safeStock }

enum ItemSort { name, stock, newest }

class ItemSearchNotifier extends Notifier<String> {
  @override
  String build() => '';
  void setState(String value) => state = value;
}

class ItemFilterNotifier extends Notifier<StockFilter> {
  @override
  StockFilter build() => StockFilter.all;
  void setState(StockFilter value) => state = value;
}

class ItemSortNotifier extends Notifier<ItemSort> {
  @override
  ItemSort build() => ItemSort.newest;
  void setState(ItemSort value) => state = value;
}

final itemSearchProvider =
    NotifierProvider<ItemSearchNotifier, String>(ItemSearchNotifier.new);
final itemFilterProvider =
    NotifierProvider<ItemFilterNotifier, StockFilter>(ItemFilterNotifier.new);
final itemSortProvider =
    NotifierProvider<ItemSortNotifier, ItemSort>(ItemSortNotifier.new);

final filteredItemsProvider = Provider.autoDispose<AsyncValue<List<Item>>>((ref) {
  final itemsAsync = ref.watch(itemsProvider);
  final searchQuery = ref.watch(itemSearchProvider).toLowerCase();
  final filter = ref.watch(itemFilterProvider);
  final sort = ref.watch(itemSortProvider);

  return itemsAsync.whenData((items) {
    var filteredList = items.where((item) {
      // Search filter
      final matchesSearch =
          item.name.toLowerCase().contains(searchQuery) ||
          (item.sku?.toLowerCase().contains(searchQuery) ?? false);

      if (!matchesSearch) return false;

      // Stock filter
      switch (filter) {
        case StockFilter.all:
          return true;
        case StockFilter.outOfStock:
          return item.quantity == 0;
        case StockFilter.lowStock:
          return item.quantity > 0 && item.quantity <= 10; // Assuming 10 is low
        case StockFilter.safeStock:
          return item.quantity > 10;
      }
    }).toList();

    // Sorting
    switch (sort) {
      case ItemSort.name:
        filteredList.sort((a, b) => a.name.compareTo(b.name));
        break;
      case ItemSort.stock:
        filteredList.sort((a, b) => a.quantity.compareTo(b.quantity));
        break;
      case ItemSort.newest:
        filteredList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    return filteredList;
  });
});

final itemDetailProvider = FutureProvider.autoDispose.family<Item, String>((
  ref,
  id,
) async {
  final repository = ref.read(itemRepositoryProvider);
  return await repository.getItemById(id);
});

// A simple Notifier to hold loading state
class ItemLoadingNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setLoading(bool val) {
    state = val;
  }
}

final itemLoadingProvider = NotifierProvider<ItemLoadingNotifier, bool>(
  ItemLoadingNotifier.new,
);

class ItemService {
  final Ref ref;

  ItemService(this.ref);

  Future<void> createItem(
    Map<String, dynamic> data,
    String? filePath,
    List<int>? fileBytes,
    String? fileExt,
  ) async {
    ref.read(itemLoadingProvider.notifier).setLoading(true);
    try {
      final repository = ref.read(itemRepositoryProvider);
      final newItem = await repository.createItem(data);

      if (filePath != null && fileBytes != null && fileExt != null) {
        final imageUrl = await repository.uploadImage(
          newItem.id,
          filePath,
          Uint8List.fromList(fileBytes),
          fileExt,
        );
        await repository.updateItem(newItem.id, {'image_url': imageUrl});
      }

      ref.invalidate(itemsProvider);
    } finally {
      ref.read(itemLoadingProvider.notifier).setLoading(false);
    }
  }

  Future<void> updateItem(
    String id,
    Map<String, dynamic> data,
    String? filePath,
    List<int>? fileBytes,
    String? fileExt,
  ) async {
    ref.read(itemLoadingProvider.notifier).setLoading(true);
    try {
      final repository = ref.read(itemRepositoryProvider);
      if (filePath != null && fileBytes != null && fileExt != null) {
        final imageUrl = await repository.uploadImage(
          id,
          filePath,
          Uint8List.fromList(fileBytes),
          fileExt,
        );
        data['image_url'] = imageUrl;
      }

      await repository.updateItem(id, data);
      ref.invalidate(itemsProvider);
      ref.invalidate(itemDetailProvider);
    } finally {
      ref.read(itemLoadingProvider.notifier).setLoading(false);
    }
  }

  Future<void> deleteItem(String id) async {
    ref.read(itemLoadingProvider.notifier).setLoading(true);
    try {
      final repository = ref.read(itemRepositoryProvider);
      await repository.deleteItem(id);
      ref.invalidate(itemsProvider);
    } finally {
      ref.read(itemLoadingProvider.notifier).setLoading(false);
    }
  }
}

final itemServiceProvider = Provider<ItemService>((ref) {
  return ItemService(ref);
});

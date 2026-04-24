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

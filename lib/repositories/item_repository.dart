import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/item.dart';

class ItemRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Item>> getItems() async {
    final response = await _client
        .from('items')
        .select()
        .order('created_at', ascending: false);

    final itemRows = (response as List<dynamic>)
        .map((json) => Map<String, dynamic>.from(json as Map))
        .toList();

    if (itemRows.isEmpty) {
      return [];
    }

    final itemIds = itemRows
        .map((item) => item['id'])
        .whereType<String>()
        .toList();
    final quantityByItemId = await _loadInventoryQuantities(itemIds);

    return itemRows.map((itemMap) {
      itemMap['quantity'] = quantityByItemId[itemMap['id']] ?? 0;
      return Item.fromJson(itemMap);
    }).toList();
  }

  Future<Item> getItemById(String id) async {
    final response = await _client.from('items').select().eq('id', id).single();
    final itemMap = Map<String, dynamic>.from(response);

    try {
      final inventoryRow = await _client
          .from('inventory')
          .select('quantity')
          .eq('item_id', id)
          .maybeSingle();
      itemMap['quantity'] = (inventoryRow?['quantity'] as num?)?.toInt() ?? 0;
    } catch (_) {
      itemMap['quantity'] = 0;
    }

    return Item.fromJson(itemMap);
  }

  Future<Item> createItem(Map<String, dynamic> data) async {
    final response = await _client.from('items').insert(data).select().single();

    // As in your system, inventory row will be auto-created and quantity will be 0
    final itemMap = Map<String, dynamic>.from(response);
    itemMap['quantity'] = 0;
    return Item.fromJson(itemMap);
  }

  Future<Item> updateItem(String id, Map<String, dynamic> data) async {
    final response = await _client
        .from('items')
        .update(data)
        .eq('id', id)
        .select()
        .single();

    // Just returning raw item, without full quantity resolution,
    // usually we reload list
    return Item.fromJson(response);
  }

  Future<void> deleteItem(String id) async {
    // Check if there is an image
    final item = await _client
        .from('items')
        .select('image_url')
        .eq('id', id)
        .single();

    final imageUrl = item['image_url']?.toString();
    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        const publicMarker = '/object/public/gambar-barang/';
        final path = imageUrl.contains(publicMarker)
            ? imageUrl.split(publicMarker).last
            : imageUrl.split('/').last;
        await _client.storage.from('gambar-barang').remove([path]);
      } catch (_) {}
    }

    await _client.from('items').delete().eq('id', id);
  }

  Future<String?> uploadImage(
    String id,
    String filePath,
    Uint8List fileBytes,
    String fileExt,
  ) async {
    final path = 'items/$id/main.$fileExt';
    await _client.storage
        .from('gambar-barang')
        .uploadBinary(path, fileBytes, fileOptions: FileOptions(upsert: true));
    return _client.storage.from('gambar-barang').getPublicUrl(path);
  }

  Future<Map<String, int>> _loadInventoryQuantities(
    List<String> itemIds,
  ) async {
    if (itemIds.isEmpty) {
      return {};
    }

    try {
      final inventoryResponse = await _client
          .from('inventory')
          .select('item_id, quantity')
          .inFilter('item_id', itemIds);

      final quantityMap = <String, int>{};
      for (final row in (inventoryResponse as List<dynamic>)) {
        final data = Map<String, dynamic>.from(row as Map);
        final itemId = data['item_id'];
        if (itemId is String) {
          quantityMap[itemId] = (data['quantity'] as num?)?.toInt() ?? 0;
        }
      }
      return quantityMap;
    } catch (_) {
      // If inventory cannot be read, still show items with fallback qty 0.
      return {};
    }
  }
}

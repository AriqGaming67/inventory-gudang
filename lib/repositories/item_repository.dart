import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/item.dart';
import '../models/stock_movement.dart';

class ItemRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 1. Fetch Items with joined Inventory
  Future<List<AppItem>> getItems() async {
    final response = await _supabase
        .from('items')
        .select('*, inventory(quantity)')
        .order('created_at', ascending: false);

    return (response as List).map((json) => AppItem.fromJson(json)).toList();
  }

  // 2. Add new item
  Future<void> addItem({
    required String name,
    String? sku,
    String? description,
    File? imageFile,
  }) async {
    String? imageUrl;

    if (imageFile != null) {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
      await _supabase.storage.from('gambar-barang').upload(fileName, imageFile);
      imageUrl = _supabase.storage.from('gambar-barang').getPublicUrl(fileName);
    }

    final response = await _supabase
        .from('items')
        .insert({
          'name': name,
          'sku': sku,
          'description': description,
          'image_url': imageUrl,
        })
        .select()
        .single();

    // Init inventory immediately to 0 for this new item to prevent missing joined data later
    await _supabase.from('inventory').insert({
      'item_id': response['id'],
      'quantity': 0,
    });
  }

  // 3. Delete item (Manager only)
  Future<void> deleteItem(String itemId, String? imageUrl) async {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        final path = imageUrl.split('gambar-barang/').last;
        await _supabase.storage.from('gambar-barang').remove([path]);
      } catch (e) {
        // Handle error gently
      }
    }
    // Note: ensure constraints like ON DELETE CASCADE exist on db,
    // otherwise manual delete on inventory & stock_movements is needed first.
    await _supabase.from('items').delete().eq('id', itemId);
  }

  // 4. Create Stock Movement (In/Out)
  Future<void> moveStock({
    required String itemId,
    required String type, // 'in' or 'out'
    required int quantity,
    String? note,
    required String userId,
  }) async {
    await _supabase.from('stock_movements').insert({
      'item_id': itemId,
      'type': type,
      'quantity': quantity,
      'note': note,
      'created_by': userId,
    });
  }

  // 5. Get recent movements
  Future<List<StockMovement>> getRecentMovements() async {
    final response = await _supabase
        .from('stock_movements')
        .select()
        .order('created_at', ascending: false)
        .limit(20);
    return (response as List)
        .map((json) => StockMovement.fromJson(json))
        .toList();
  }
}

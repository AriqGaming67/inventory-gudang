import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/stock_movement.dart';

class StockRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<StockMovement>> getStockMovements({String? itemId}) async {
    var query = _client.from('stock_movements').select();

    if (itemId != null) {
      query = query.eq('item_id', itemId);
    }

    var orderedQuery = query.order('created_at', ascending: false);

    if (itemId != null) {
      orderedQuery = orderedQuery.limit(5);
    }

    final response = await orderedQuery;
    final rows = (response as List<dynamic>)
        .map((json) => Map<String, dynamic>.from(json as Map))
        .toList();

    if (rows.isEmpty) {
      return [];
    }

    final itemNamesById = await _loadItemNames(rows);
    final profileNamesById = await _loadProfileNames(rows);

    return rows.map((row) {
      row['item_name'] = itemNamesById[row['item_id']];
      row['created_by_name'] = profileNamesById[row['created_by']];
      return StockMovement.fromJson(row);
    }).toList();
  }

  Future<void> createStockMovement(Map<String, dynamic> data) async {
    await _client.from('stock_movements').insert(data);
  }

  Future<void> deleteStockMovement(String id) async {
    await _client.from('stock_movements').delete().eq('id', id);
  }

  Future<Map<String, String>> _loadItemNames(
    List<Map<String, dynamic>> rows,
  ) async {
    final itemIds = rows
        .map((row) => row['item_id'])
        .whereType<String>()
        .toSet()
        .toList();

    if (itemIds.isEmpty) {
      return {};
    }

    try {
      final response = await _client
          .from('items')
          .select('id, name')
          .inFilter('id', itemIds);

      final result = <String, String>{};
      for (final item in (response as List<dynamic>)) {
        final row = Map<String, dynamic>.from(item as Map);
        final id = row['id'];
        if (id is String) {
          result[id] = row['name']?.toString() ?? '-';
        }
      }
      return result;
    } catch (_) {
      return {};
    }
  }

  Future<Map<String, String>> _loadProfileNames(
    List<Map<String, dynamic>> rows,
  ) async {
    final profileIds = rows
        .map((row) => row['created_by'])
        .whereType<String>()
        .toSet()
        .toList();

    if (profileIds.isEmpty) {
      return {};
    }

    try {
      final response = await _client
          .from('profiles')
          .select('id, name')
          .inFilter('id', profileIds);

      final result = <String, String>{};
      for (final profile in (response as List<dynamic>)) {
        final row = Map<String, dynamic>.from(profile as Map);
        final id = row['id'];
        if (id is String) {
          result[id] = row['name']?.toString() ?? '-';
        }
      }
      return result;
    } catch (_) {
      return {};
    }
  }
}

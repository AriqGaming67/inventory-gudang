import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/item_provider.dart';
import '../../providers/stock_provider.dart';
import '../../widgets/stock_badge.dart';
import '../../widgets/animated_button.dart';
import '../stock/stock_movement_screen.dart';
import 'add_edit_item_screen.dart';

class ItemDetailScreen extends ConsumerWidget {
  final String itemId;

  const ItemDetailScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(itemDetailProvider(itemId));
    final stockHistoryAsync = ref.watch(stockMovementsProvider(itemId));
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Detail Barang',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      body: itemAsync.when(
        data: (item) {
          return Container(
            color: colorScheme.surface,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Image Container
                  Container(
                    height: 360,
                    width: double.infinity,
                    color: colorScheme.surfaceContainer,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        item.imageUrl != null
                            ? Image.network(
                                item.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Center(
                                      child: Icon(
                                        Icons.inventory_2,
                                        size: 100,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                              )
                            : Center(
                                child: Icon(
                                  Icons.inventory_2,
                                  size: 100,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                        // Edit button overlay
                        Positioned(
                          top: 16,
                          right: 16,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AddEditItemScreen(item: item),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w700,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.qr_code_2,
                                        size: 14,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'SKU: ${item.sku ?? '-'}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            StockBadge(quantity: item.quantity),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Description Section
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: colorScheme.outlineVariant,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Deskripsi',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item.description ?? 'Tidak ada deskripsi.',
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Action Buttons
                        Text(
                          'Kelola Stok',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: AnimatedElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => StockMovementScreen(
                                        initialItem: item,
                                        type: 'in',
                                      ),
                                    ),
                                  );
                                },
                                label: 'Stock In',
                                icon: Icons.add_circle_outline,
                                backgroundColor: const Color(0xFF16A34A),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AnimatedElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => StockMovementScreen(
                                        initialItem: item,
                                        type: 'out',
                                      ),
                                    ),
                                  );
                                },
                                label: 'Stock Out',
                                icon: Icons.remove_circle_outline,
                                backgroundColor: const Color(0xFFDC2626),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        // Transaction History
                        Text(
                          'Riwayat Transaksi Terakhir',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        stockHistoryAsync.when(
                          data: (history) {
                            if (history.isEmpty) {
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest
                                      .withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: colorScheme.outlineVariant,
                                  ),
                                ),
                                child: Text(
                                  'Belum ada riwayat transaksi.',
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            }
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: history.length,
                              itemBuilder: (context, index) {
                                final mov = history[index];
                                final isIn = mov.type == 'in';
                                return Card(
                                  elevation: 0,
                                  color: colorScheme.surfaceContainerHighest
                                      .withValues(alpha: 0.18),
                                  margin: const EdgeInsets.only(bottom: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(
                                      color: colorScheme.outlineVariant,
                                    ),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    leading: CircleAvatar(
                                      backgroundColor: isIn
                                          ? const Color(
                                              0xFF16A34A,
                                            ).withValues(alpha: 0.1)
                                          : const Color(
                                              0xFFDC2626,
                                            ).withValues(alpha: 0.1),
                                      child: Icon(
                                        isIn
                                            ? Icons.arrow_downward
                                            : Icons.arrow_upward,
                                        color: isIn
                                            ? const Color(0xFF16A34A)
                                            : const Color(0xFFDC2626),
                                        size: 18,
                                      ),
                                    ),
                                    title: Text(
                                      isIn
                                          ? '+${mov.quantity} unit (Masuk)'
                                          : '-${mov.quantity} unit (Keluar)',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.onSurface,
                                        fontSize: 13,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        if (mov.note != null &&
                                            mov.note!.isNotEmpty)
                                          Text(
                                            mov.note!,
                                            style: TextStyle(
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                              fontSize: 12,
                                            ),
                                          ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Oleh: ${mov.createdByName ?? '-'} • ${mov.createdAt.toLocal().toString().split('.')[0]}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                    isThreeLine:
                                        mov.note != null &&
                                        mov.note!.isNotEmpty,
                                  ),
                                );
                              },
                            );
                          },
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (error, stack) => Text(
                            'Error: $error',
                            style: TextStyle(color: colorScheme.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => Center(
          child: Container(
            color: colorScheme.surface,
            child: const CircularProgressIndicator(),
          ),
        ),
        error: (error, stack) => Container(
          color: colorScheme.surface,
          child: Center(
            child: Text(
              'Error: $error',
              style: TextStyle(color: colorScheme.error),
            ),
          ),
        ),
      ),
    );
  }
}

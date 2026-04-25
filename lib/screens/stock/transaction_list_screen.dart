import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/stock_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/delete_confirmation_dialog.dart';

class TransactionFilter extends Notifier<String> {
  @override
  String build() => 'all';

  void setFilter(String value) {
    state = value;
  }
}

final transactionFilterTypeProvider =
    NotifierProvider<TransactionFilter, String>(TransactionFilter.new);

class TransactionListScreen extends ConsumerWidget {
  const TransactionListScreen({super.key});

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    String movementId,
    String itemName,
    int quantity,
    bool isIn,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return DeleteConfirmationDialog(
          title: 'Hapus Transaksi',
          message:
              'Apakah Anda yakin ingin menghapus transaksi "${isIn ? 'Masuk' : 'Keluar'}" untuk "$itemName" ($quantity unit)? Tindakan ini tidak dapat dibatalkan.',
          onConfirm: () async {
            try {
              await ref
                  .read(stockServiceProvider)
                  .deleteStockMovement(movementId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Transaksi berhasil dihapus'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movementsAsync = ref.watch(stockMovementsProvider(null));
    final filterType = ref.watch(transactionFilterTypeProvider);
    final isLoading = ref.watch(stockLoadingProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(
          'Riwayat Transaksi',
          style: TextStyle(color: colorScheme.onSurface),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: Container(
        color: colorScheme.surface,
        child: Column(
          children: [
            Container(
              color: colorScheme.surface,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'all', label: Text('Semua')),
                        ButtonSegment(value: 'in', label: Text('Masuk')),
                        ButtonSegment(value: 'out', label: Text('Keluar')),
                      ],
                      selected: {filterType},
                      onSelectionChanged: (Set<String> newSelection) {
                        ref
                            .read(transactionFilterTypeProvider.notifier)
                            .setFilter(newSelection.first);
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.resolveWith<Color>(
                          (Set<WidgetState> states) {
                            if (states.contains(WidgetState.selected)) {
                              return const Color(
                                0xFF2563EB,
                              ).withValues(alpha: 0.1);
                            }
                            return colorScheme.surface;
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: movementsAsync.when(
                data: (movements) {
                  final filtered = filterType == 'all'
                      ? movements
                      : movements.where((m) => m.type == filterType).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.swap_horiz,
                            size: 64,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada transaksi.',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final mov = filtered[index];
                      final isIn = mov.type == 'in';
                      final dateStr = mov.createdAt
                          .toLocal()
                          .toString()
                          .substring(0, 16);

                      return Card(
                        elevation: 2,
                        color: colorScheme.surface,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: colorScheme.outlineVariant,
                            width: 1.2,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: isIn
                                    ? [
                                        const Color(
                                          0xFF16A34A,
                                        ).withValues(alpha: 0.2),
                                        const Color(
                                          0xFF10B981,
                                        ).withValues(alpha: 0.1),
                                      ]
                                    : [
                                        const Color(
                                          0xFFDC2626,
                                        ).withValues(alpha: 0.2),
                                        const Color(
                                          0xFFF87171,
                                        ).withValues(alpha: 0.1),
                                      ],
                              ),
                            ),
                            child: Icon(
                              isIn ? Icons.arrow_downward : Icons.arrow_upward,
                              color: isIn
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFFDC2626),
                              size: 24,
                            ),
                          ),
                          title: Text(
                            mov.itemName ?? 'Barang Dihapus',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 6),
                              if (mov.note != null && mov.note!.isNotEmpty) ...[
                                Text(
                                  mov.note!,
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                              ],
                              Row(
                                children: [
                                  Icon(
                                    Icons.person_2_outlined,
                                    size: 12,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      '${mov.createdByName ?? '-'} • $dateStr',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            enabled: !isLoading,
                            onSelected: (value) {
                              if (value == 'delete') {
                                _showDeleteDialog(
                                  context,
                                  ref,
                                  mov.id,
                                  mov.itemName ?? '-',
                                  mov.quantity,
                                  isIn,
                                );
                              }
                            },
                            itemBuilder: (BuildContext context) => [
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Hapus',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            icon: Icon(
                              Icons.more_vert,
                              color: colorScheme.onSurfaceVariant,
                              size: 18,
                            ),
                          ),
                          isThreeLine: mov.note != null && mov.note!.isNotEmpty,
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(
                  child: Text(
                    'Error: $err',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

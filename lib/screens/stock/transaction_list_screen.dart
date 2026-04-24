import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/stock_provider.dart';
import '../../widgets/app_drawer.dart';

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movementsAsync = ref.watch(stockMovementsProvider(null));
    final filterType = ref.watch(transactionFilterTypeProvider);
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
      body: Column(
        children: [
          Container(
            color: colorScheme.surface,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      backgroundColor: WidgetStateProperty.resolveWith<Color>((
                        Set<WidgetState> states,
                      ) {
                        if (states.contains(WidgetState.selected)) {
                          return const Color(0xFF2563EB).withValues(alpha: 0.1);
                        }
                        return colorScheme.surface;
                      }),
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
                      elevation: 0,
                      color: colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.18,
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: colorScheme.outlineVariant),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              (isIn
                                      ? const Color(0xFF16A34A)
                                      : const Color(0xFFDC2626))
                                  .withValues(alpha: 0.1),
                          child: Icon(
                            isIn ? Icons.arrow_downward : Icons.arrow_upward,
                            color: isIn
                                ? const Color(0xFF16A34A)
                                : const Color(0xFFDC2626),
                          ),
                        ),
                        title: Text(
                          mov.itemName ?? 'Barang Dihapus',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            if (mov.note != null && mov.note!.isNotEmpty) ...[
                              Text(
                                mov.note!,
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 2),
                            ],
                            Text(
                              'Oleh: ${mov.createdByName ?? '-'} - $dateStr',
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        trailing: Text(
                          isIn ? '+${mov.quantity}' : '-${mov.quantity}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isIn
                                ? const Color(0xFF16A34A)
                                : const Color(0xFFDC2626),
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
    );
  }
}

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/item.dart';
import '../providers/item_provider.dart';
import '../widgets/app_drawer.dart';

final dashboardStatsProvider = FutureProvider.autoDispose<_DashboardSnapshot>((
  ref,
) async {
  final items = await ref.watch(itemsProvider.future);

  var totalStock = 0;
  var lowStockCount = 0;
  var emptyStockCount = 0;

  for (final item in items) {
    totalStock += item.quantity;
    if (item.quantity == 0) {
      emptyStockCount++;
    } else if (item.quantity < 5) {
      lowStockCount++;
    }
  }

  return _DashboardSnapshot(
    items: items,
    totalItems: items.length,
    totalStock: totalStock,
    lowStockCount: lowStockCount,
    emptyStockCount: emptyStockCount,
  );
});

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsyncValue = ref.watch(dashboardStatsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: statsAsyncValue.when(
        data: (snapshot) => _DashboardContent(snapshot: snapshot),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => _DashboardError(message: 'Error: $err'),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.snapshot});

  final _DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final healthyItems = snapshot.healthyItems;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 920;
        final crossAxisCount = constraints.maxWidth >= 1100
            ? 4
            : constraints.maxWidth >= 680
            ? 2
            : 1;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ringkasan Operasional',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Pantau kesehatan stok dan barang terbaru dalam satu tampilan.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    childAspectRatio: crossAxisCount == 1 ? 2.25 : 1.2,
                    children: [
                      _StatTile(
                        title: 'Total Barang',
                        value: '${snapshot.totalItems}',
                        note: 'Item terdaftar',
                        icon: Icons.inventory_2_rounded,
                        accent: colorScheme.primary,
                      ),
                      _StatTile(
                        title: 'Total Stok',
                        value: '${snapshot.totalStock}',
                        note: 'Unit tersedia',
                        icon: Icons.layers_rounded,
                        accent: Colors.green.shade600,
                      ),
                      _StatTile(
                        title: 'Stok Rendah',
                        value: '${snapshot.lowStockCount}',
                        note: 'Kurang dari 5 unit',
                        icon: Icons.warning_amber_rounded,
                        accent: Colors.orange.shade700,
                      ),
                      _StatTile(
                        title: 'Stok Habis',
                        value: '${snapshot.emptyStockCount}',
                        note: 'Perlu segera diisi',
                        icon: Icons.remove_shopping_cart_rounded,
                        accent: Colors.red.shade600,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: _StockInsightPanel(snapshot: snapshot),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 4,
                          child: _RecentItemsPanel(items: snapshot.recentItems),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _StockInsightPanel(snapshot: snapshot),
                        const SizedBox(height: 16),
                        _RecentItemsPanel(items: snapshot.recentItems),
                      ],
                    ),
                  const SizedBox(height: 16),
                  _ActionNote(
                    message: snapshot.totalItems == 0
                        ? 'Belum ada barang terdaftar. Mulai tambahkan item agar dashboard bisa menampilkan insight stok.'
                        : snapshot.emptyStockCount > 0
                        ? 'Ada ${snapshot.emptyStockCount} barang yang sudah habis. '
                              'Prioritaskan restock untuk menjaga operasional tetap lancar.'
                        : snapshot.lowStockCount > 0
                        ? 'Ada ${snapshot.lowStockCount} barang dengan stok menipis. '
                              'Saat yang pas untuk siapkan pengadaan berikutnya.'
                        : 'Semua barang berada di kondisi aman. Dashboard ini bisa jadi '
                              'checkpoint cepat sebelum aktivitas gudang dimulai.',
                    healthyItems: healthyItems,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.title,
    required this.value,
    required this.note,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String value;
  final String note;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accent),
          ),
          const Spacer(),
          Text(
            value,
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            note,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _StockInsightPanel extends StatelessWidget {
  const _StockInsightPanel({required this.snapshot});

  final _DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final totalItems = snapshot.totalItems == 0 ? 1 : snapshot.totalItems;
    final healthyRatio = snapshot.healthyItems / totalItems;
    final lowRatio = snapshot.lowStockCount / totalItems;
    final emptyRatio = snapshot.emptyStockCount / totalItems;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ketersediaan Stok',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Proporsi stok aman, menipis, dan habis dari seluruh barang.',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 1),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 9,
              child: Row(
                children: [
                  if (healthyRatio > 0)
                    Expanded(
                      flex: _progressFlex(healthyRatio),
                      child: ColoredBox(color: colorScheme.primary),
                    ),
                  if (lowRatio > 0)
                    Expanded(
                      flex: _progressFlex(lowRatio),
                      child: ColoredBox(color: Colors.orange.shade700),
                    ),
                  if (emptyRatio > 0)
                    Expanded(
                      flex: _progressFlex(emptyRatio),
                      child: ColoredBox(color: Colors.red.shade600),
                    ),
                  if (snapshot.totalItems == 0)
                    Expanded(
                      child: ColoredBox(color: colorScheme.surfaceContainerHigh),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          _StatusLegend(
            label: 'Aman',
            value: snapshot.healthyItems,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 12),
          _StatusLegend(
            label: 'Menipis',
            value: snapshot.lowStockCount,
            color: Colors.orange.shade700,
          ),
          const SizedBox(height: 12),
          _StatusLegend(
            label: 'Habis',
            value: snapshot.emptyStockCount,
            color: Colors.red.shade600,
          ),
          const SizedBox(height: 18),
          Divider(color: colorScheme.outlineVariant),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _InfoChip(
                icon: Icons.check_circle_outline_rounded,
                label: '${snapshot.healthyItems} item siap dipakai',
              ),
              _InfoChip(
                icon: Icons.schedule_rounded,
                label: '${snapshot.recentItems.length} item terbaru dipantau',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusLegend extends StatelessWidget {
  const _StatusLegend({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        Text(
          '$value',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentItemsPanel extends StatelessWidget {
  const _RecentItemsPanel({required this.items});

  final List<Item> items;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Barang Terbaru',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Item yang paling baru masuk ke daftar inventaris.',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                'Belum ada data barang untuk ditampilkan.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _RecentItemTile(item: item),
                )),
        ],
      ),
    );
  }
}

class _RecentItemTile extends StatelessWidget {
  const _RecentItemTile({required this.item});

  final Item item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final stockColor = item.quantity == 0
        ? Colors.red.shade600
        : item.quantity < 5
        ? Colors.orange.shade700
        : colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: stockColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              item.name.isNotEmpty ? item.name[0].toUpperCase() : '?',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: stockColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.sku?.isNotEmpty == true
                      ? 'SKU ${item.sku}'
                      : 'Ditambahkan ${_formatDate(item.createdAt)}',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: stockColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '${item.quantity} unit',
              style: textTheme.labelLarge?.copyWith(
                color: stockColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionNote extends StatelessWidget {
  const _ActionNote({required this.message, required this.healthyItems});

  final String message;
  final int healthyItems;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.insights_rounded, color: colorScheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Catatan Hari Ini',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '$healthyItems barang berada di level stok aman.',
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardError extends StatelessWidget {
  const _DashboardError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.errorContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, color: colorScheme.error),
              const SizedBox(height: 12),
              Text(
                'Dashboard tidak bisa dimuat',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardSnapshot {
  const _DashboardSnapshot({
    required this.items,
    required this.totalItems,
    required this.totalStock,
    required this.lowStockCount,
    required this.emptyStockCount,
  });

  final List<Item> items;
  final int totalItems;
  final int totalStock;
  final int lowStockCount;
  final int emptyStockCount;

  int get healthyItems => totalItems - lowStockCount - emptyStockCount;

  List<Item> get recentItems => items.take(4).toList();
}

String _formatDate(DateTime date) {
  const monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  return '${date.day} ${monthNames[date.month - 1]} ${date.year}';
}

int _progressFlex(double ratio) => math.max(1, (ratio * 100).round());

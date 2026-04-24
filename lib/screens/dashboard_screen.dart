import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/item_provider.dart';
import '../widgets/app_drawer.dart';

final dashboardStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>(
  (ref) async {
    final items = await ref.watch(itemsProvider.future);
    int totalStock = 0;
    int lowStockCount = 0;
    for (var item in items) {
      totalStock += item.quantity;
      if (item.quantity < 5) lowStockCount++;
    }
    return {
      'totalItems': items.length,
      'totalStock': totalStock,
      'lowStockCount': lowStockCount,
    };
  },
);

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsyncValue = ref.watch(dashboardStatsProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Dashboard'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: statsAsyncValue.when(
        data: (stats) {
          final totalItems = stats['totalItems'] as int? ?? 0;
          final totalStock = stats['totalStock'] as int? ?? 0;
          final lowStockCount = stats['lowStockCount'] as int? ?? 0;
          final healthyItems = totalItems - lowStockCount;
          final screenWidth = MediaQuery.of(context).size.width;
          final isSmallScreen = screenWidth < 480;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ringkasan Gudang',
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pantau kondisi stok secara cepat',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 16),
                      GridView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          mainAxisExtent: isSmallScreen ? 136 : 160,
                        ),
                        children: [
                          _buildStatCard(
                            context: context,
                            title: 'Total Barang',
                            value: '$totalItems',
                            subtitle: 'Terdaftar',
                            icon: Icons.inventory_2,
                            color: const Color(0xFF2563EB),
                          ),
                          _buildStatCard(
                            context: context,
                            title: 'Total Stok',
                            value: '$totalStock',
                            subtitle: 'Unit tersedia',
                            icon: Icons.stacked_bar_chart,
                            color: const Color(0xFF16A34A),
                          ),
                          _buildStatCard(
                            context: context,
                            title: 'Stok Rendah',
                            value: '$lowStockCount',
                            subtitle: 'Butuh restock',
                            icon: Icons.warning_amber,
                            color: const Color(0xFFD97706),
                          ),
                          _buildStatCard(
                            context: context,
                            title: 'Stok Aman',
                            value: '${healthyItems < 0 ? 0 : healthyItems}',
                            subtitle: 'Kondisi normal',
                            icon: Icons.verified,
                            color: const Color(0xFF0EA5E9),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF2563EB).withValues(
                              alpha: 0.2,
                            ),
                          ),
                        ),
                        child: Text(
                          lowStockCount > 0
                              ? 'Perhatian: ada $lowStockCount barang dengan stok rendah.'
                              : 'Semua stok dalam kondisi aman saat ini.',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.25), width: 1),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact =
              constraints.maxHeight <= 136 || constraints.maxWidth <= 180;
          final padding = compact ? 10.0 : 14.0;
          final iconBoxSize = compact ? 28.0 : 34.0;
          final iconSize = compact ? 16.0 : 20.0;
          final valueFontSize = compact ? 20.0 : 26.0;
          final titleFontSize = compact ? 12.0 : 14.0;
          final subtitleFontSize = compact ? 10.0 : 12.0;
          final gapAfterIcon = compact ? 6.0 : 10.0;
          final gapAfterValue = compact ? 4.0 : 8.0;
          final gapAfterTitle = 0.0;

          return Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: iconBoxSize,
                  height: iconBoxSize,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: iconSize, color: color),
                ),
                SizedBox(height: gapAfterIcon),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: valueFontSize,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                SizedBox(height: gapAfterValue),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: gapAfterTitle),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: subtitleFontSize,
                    color: colorScheme.onSurfaceVariant,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

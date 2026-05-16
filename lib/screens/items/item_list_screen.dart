import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/item_provider.dart';
import '../../widgets/item_card.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/animated_button.dart';
import 'item_detail_screen.dart';
import 'add_edit_item_screen.dart';

class ItemListScreen extends ConsumerWidget {
  const ItemListScreen({super.key});

  void _showFilterSheet(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(itemFilterProvider);
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter Stok',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: StockFilter.values.map((filter) {
                  final isSelected = currentFilter == filter;
                  String label = '';
                  switch (filter) {
                    case StockFilter.all:
                      label = 'Semua';
                      break;
                    case StockFilter.outOfStock:
                      label = 'Stok Habis';
                      break;
                    case StockFilter.lowStock:
                      label = 'Stok Rendah';
                      break;
                    case StockFilter.safeStock:
                      label = 'Stok Aman';
                      break;
                  }
                  return FilterChip(
                    selected: isSelected,
                    label: Text(label),
                    onSelected: (selected) {
                      ref.read(itemFilterProvider.notifier).setState(filter);
                      Navigator.pop(context);
                    },
                    selectedColor: colorScheme.primaryContainer,
                    checkmarkColor: colorScheme.primary,
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSortSheet(BuildContext context, WidgetRef ref) {
    final currentSort = ref.watch(itemSortProvider);
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Urutkan Berdasarkan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Nama (A-Z)'),
                leading: Icon(
                  Icons.sort_by_alpha,
                  color: currentSort == ItemSort.name
                      ? colorScheme.primary
                      : null,
                ),
                trailing: currentSort == ItemSort.name
                    ? Icon(Icons.check, color: colorScheme.primary)
                    : null,
                onTap: () {
                  ref.read(itemSortProvider.notifier).setState(ItemSort.name);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Stok (Terendah)'),
                leading: Icon(
                  Icons.inventory_2_outlined,
                  color: currentSort == ItemSort.stock
                      ? colorScheme.primary
                      : null,
                ),
                trailing: currentSort == ItemSort.stock
                    ? Icon(Icons.check, color: colorScheme.primary)
                    : null,
                onTap: () {
                  ref.read(itemSortProvider.notifier).setState(ItemSort.stock);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Terbaru'),
                leading: Icon(
                  Icons.calendar_today_outlined,
                  color: currentSort == ItemSort.newest
                      ? colorScheme.primary
                      : null,
                ),
                trailing: currentSort == ItemSort.newest
                    ? Icon(Icons.check, color: colorScheme.primary)
                    : null,
                onTap: () {
                  ref.read(itemSortProvider.notifier).setState(ItemSort.newest);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(filteredItemsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(
          'Daftar Barang',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
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
      body: itemsAsync.when(
        data: (items) {
          final searchQuery = ref.watch(itemSearchProvider);
          final filter = ref.watch(itemFilterProvider);
          final isFiltered =
              searchQuery.isNotEmpty || filter != StockFilter.all;

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(
                        alpha: 0.3,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFiltered ? Icons.search_off : Icons.inventory_2,
                      size: 48,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    isFiltered ? 'Barang tidak ditemukan' : 'Belum ada barang',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isFiltered
                        ? 'Coba ubah kata kunci atau filter pencarian Anda'
                        : 'Silakan tambahkan barang baru dari tombol di bawah',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 32),
                  if (isFiltered)
                    OutlinedButton(
                      onPressed: () {
                        ref.read(itemSearchProvider.notifier).setState('');
                        ref
                            .read(itemFilterProvider.notifier)
                            .setState(StockFilter.all);
                      },
                      child: const Text('Reset Pencarian'),
                    )
                  else
                    AnimatedElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddEditItemScreen(),
                          ),
                        );
                      },
                      label: 'Tambah Barang',
                      icon: Icons.add,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                ],
              ),
            );
          }
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceVariant.withValues(
                            alpha: 0.3,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextField(
                          onChanged: (value) =>
                              ref.read(itemSearchProvider.notifier).setState(
                                    value,
                                  ),
                          decoration: InputDecoration(
                            hintText: 'Cari nama atau SKU...',
                            prefixIcon: const Icon(Icons.search),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _showFilterSheet(context, ref),
                              icon: const Icon(Icons.filter_list),
                              label: const Text('Filter'),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _showSortSheet(context, ref),
                              icon: const Icon(Icons.swap_vert),
                              label: const Text('Urutkan'),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(
                        alpha: 0.1,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: colorScheme.primaryContainer.withValues(
                          alpha: 0.2,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: colorScheme.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Menampilkan ${items.length} barang',
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final item = items[index];
                    return ItemCard(
                      item: item,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ItemDetailScreen(itemId: item.id),
                          ),
                        );
                      },
                    );
                  }, childCount: items.length),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: colorScheme.error),
              const SizedBox(height: 16),
              Text(
                'Terjadi kesalahan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: TextStyle(color: colorScheme.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              AnimatedElevatedButton(
                onPressed: () => ref.invalidate(itemsProvider),
                label: 'Coba Lagi',
                icon: Icons.refresh,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

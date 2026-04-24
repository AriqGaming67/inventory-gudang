import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/item_provider.dart';
import '../../providers/stock_provider.dart';
import '../../models/item.dart';

class StockMovementScreen extends ConsumerStatefulWidget {
  final Item? initialItem;
  final String? type; // 'in' or 'out'

  const StockMovementScreen({super.key, this.initialItem, this.type});

  @override
  ConsumerState<StockMovementScreen> createState() =>
      _StockMovementScreenState();
}

class _StockMovementScreenState extends ConsumerState<StockMovementScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _type;
  Item? _selectedItem;
  final _quantityController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _type = widget.type ?? 'in';
    _selectedItem = widget.initialItem;
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedItem == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Pilih barang terlebih dahulu',
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
      return;
    }

    final quantity = int.tryParse(_quantityController.text) ?? 0;
    if (_type == 'out' && quantity > _selectedItem!.quantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Jumlah keluar melebihi stok yang ada!',
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
      return;
    }

    final user = Supabase.instance.client.auth.currentUser;

    final data = {
      'item_id': _selectedItem!.id,
      'type': _type,
      'quantity': quantity,
      'note': _noteController.text.isEmpty ? null : _noteController.text,
      'created_by': user?.id,
    };

    try {
      await ref.read(stockServiceProvider).createStockMovement(data);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Transaksi berhasil dicatat',
              style: TextStyle(color: Colors.green),
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: $e',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(itemsProvider);
    final isLoading = ref.watch(stockLoadingProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final fieldFillColor = colorScheme.surfaceContainerHighest.withValues(
      alpha: 0.18,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Catat Transaksi',
          style: TextStyle(color: colorScheme.onSurface),
        ),
        backgroundColor: colorScheme.surface,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      backgroundColor: colorScheme.surface,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment<String>(
                          value: 'in',
                          label: Text('Stock Masuk'),
                          icon: Icon(Icons.arrow_downward),
                        ),
                        ButtonSegment<String>(
                          value: 'out',
                          label: Text('Stock Keluar'),
                          icon: Icon(Icons.arrow_upward),
                        ),
                      ],
                      selected: {_type},
                      onSelectionChanged: (Set<String> newSelection) {
                        setState(() {
                          _type = newSelection.first;
                        });
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.resolveWith<Color>(
                          (Set<WidgetState> states) {
                            if (states.contains(WidgetState.selected)) {
                              return _type == 'in'
                                  ? const Color(
                                      0xFF16A34A,
                                    ).withValues(alpha: 0.2)
                                  : const Color(
                                      0xFFDC2626,
                                    ).withValues(alpha: 0.2);
                            }
                            return colorScheme.surface;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    itemsAsync.when(
                      data: (items) {
                        if (items.isEmpty) {
                          return const Text(
                            'Belum ada barang, tambahkan barang dulu.',
                          );
                        }
                        return DropdownButtonFormField<Item>(
                          decoration: InputDecoration(
                            labelText: 'Barang',
                            border: const OutlineInputBorder(),
                            filled: true,
                            fillColor: fieldFillColor,
                          ),
                          initialValue: _selectedItem != null
                              ? items.firstWhere(
                                  (i) => i.id == _selectedItem!.id,
                                  orElse: () => items.first,
                                )
                              : null,
                          items: items.map((item) {
                            return DropdownMenuItem<Item>(
                              value: item,
                              child: Text(
                                '${item.name} (Stok: ${item.quantity})',
                              ),
                            );
                          }).toList(),
                          onChanged: (Item? newValue) {
                            setState(() {
                              _selectedItem = newValue;
                            });
                          },
                        );
                      },
                      loading: () => const CircularProgressIndicator(),
                      error: (err, stack) => Text('Error loading items: $err'),
                    ),
                    if (_selectedItem != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                        child: Text(
                          'Stok saat ini: ${_selectedItem!.quantity}',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Jumlah *',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: fieldFillColor,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Jumlah wajib diisi';
                        }
                        final q = int.tryParse(value);
                        if (q == null || q <= 0) {
                          return 'Jumlah harus angka positif';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _noteController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Catatan (Opsional)',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: fieldFillColor,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: _submit,
                      child: const Text(
                        'Simpan Transaksi',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

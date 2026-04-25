import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../../providers/item_provider.dart';
import '../../widgets/animated_button.dart';
import '../../models/item.dart';

class AddEditItemScreen extends ConsumerStatefulWidget {
  final Item? item;

  const AddEditItemScreen({super.key, this.item});

  @override
  ConsumerState<AddEditItemScreen> createState() => _AddEditItemScreenState();
}

class _AddEditItemScreenState extends ConsumerState<AddEditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _skuController;
  late TextEditingController _descriptionController;
  XFile? _imageFile;
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _skuController = TextEditingController(text: widget.item?.sku ?? '');
    _descriptionController = TextEditingController(
      text: widget.item?.description ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageFile = pickedFile;
        _imageBytes = bytes;
      });
    }
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'name': _nameController.text,
      'sku': _skuController.text.isEmpty ? null : _skuController.text,
      'description': _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
    };

    String? filePath;
    List<int>? fileBytes;
    String? fileExt;

    if (_imageFile != null) {
      filePath = _imageFile!.name;
      fileBytes = _imageBytes ?? await _imageFile!.readAsBytes();
      final nameParts = _imageFile!.name.split('.');
      fileExt = nameParts.length > 1 ? nameParts.last.toLowerCase() : 'jpg';
    }

    try {
      if (widget.item == null) {
        await ref
            .read(itemServiceProvider)
            .createItem(data, filePath, fileBytes, fileExt);
      } else {
        await ref
            .read(itemServiceProvider)
            .updateItem(widget.item!.id, data, filePath, fileBytes, fileExt);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.item == null
                  ? 'Barang berhasil ditambahkan'
                  : 'Barang berhasil diperbarui',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(itemLoadingProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          widget.item == null ? 'Tambah Barang Baru' : 'Edit Barang',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      body: isLoading
          ? Center(
              child: Container(
                color: colorScheme.surface,
                child: const CircularProgressIndicator(),
              ),
            )
          : Container(
              color: colorScheme.surface,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Image Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withValues(
                            alpha: 0.18,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: colorScheme.outlineVariant),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Foto Barang',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  width: 160,
                                  height: 160,
                                  decoration: BoxDecoration(
                                    color: colorScheme.surfaceContainer,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: colorScheme.outlineVariant,
                                      width: 2,
                                    ),
                                  ),
                                  child: _imageBytes != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          child: Image.memory(
                                            _imageBytes!,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : (widget.item?.imageUrl != null
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                child: Image.network(
                                                  widget.item!.imageUrl!,
                                                  fit: BoxFit.cover,
                                                  errorBuilder:
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) {
                                                        return Icon(
                                                          Icons.add_a_photo,
                                                          size: 50,
                                                          color: colorScheme
                                                              .onSurfaceVariant,
                                                        );
                                                      },
                                                ),
                                              )
                                            : Icon(
                                                Icons.add_a_photo,
                                                size: 50,
                                                color: colorScheme
                                                    .onSurfaceVariant,
                                              )),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Tap untuk pilih foto',
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      // Form Section
                      Text(
                        'Informasi Barang',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Nama Barang *',
                          hintText: 'Masukkan nama barang',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.18),
                          prefixIcon: const Icon(Icons.inventory_2),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Nama barang tidak boleh kosong'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _skuController,
                        decoration: InputDecoration(
                          labelText: 'SKU (Opsional)',
                          hintText: 'e.g., SKU-001',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.18),
                          prefixIcon: const Icon(Icons.qr_code_2),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: 'Deskripsi (Opsional)',
                          hintText: 'Deskripsikan detail barang...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.18),
                          prefixIcon: const Icon(Icons.description_outlined),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: AnimatedOutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              label: 'Batal',
                              borderColor: colorScheme.outlineVariant,
                              textColor: colorScheme.onSurface,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AnimatedElevatedButton(
                              onPressed: _saveItem,
                              icon: Icons.check,
                              label: widget.item == null
                                  ? 'Tambah'
                                  : 'Perbarui',
                              backgroundColor: const Color(0xFF2563EB),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

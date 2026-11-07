import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/file_save_service.dart';
import '../pdf_provider/pdf_tools_provider.dart';
import '../pdf_utils/pdf_models.dart';

class ImageToPdfScreen extends ConsumerWidget {
  const ImageToPdfScreen({super.key});

  Future<void> _pickImage(BuildContext context, WidgetRef ref, ImageSource source) async {
    final picker = ImagePicker();
    try {
      if (source == ImageSource.gallery) {
        final List<XFile> picked = await picker.pickMultiImage();
        if (picked.isNotEmpty) {
          ref.read(imageToPdfProvider.notifier).addImages(picked);
        }
      } else {
        final XFile? photo = await picker.pickImage(source: ImageSource.camera);
        if (photo != null) {
          ref.read(imageToPdfProvider.notifier).addImages([photo]);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image selection error: $e')),
        );
      }
    }
  }

  void _showSourcePickerModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.blue),
                title: const Text('Pick from Gallery'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(context, ref, ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.green),
                title: const Text('Capture with Camera'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(context, ref, ImageSource.camera);
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
    final state = ref.watch(imageToPdfProvider);
    final notifier = ref.read(imageToPdfProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Image to PDF Converter')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          pdfHero('Image to PDF', 'Convert photos from gallery or camera into a clean High-Quality PDF', Colors.red, Icons.picture_as_pdf),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: state.pageSize,
                    decoration: const InputDecoration(labelText: 'Page Size', border: OutlineInputBorder()),
                    items: ['A4', 'Letter', 'Legal'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (v) {
                      if (v != null) notifier.setPageSize(v);
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Portrait'),
                          selected: state.orientation == 'Portrait',
                          onSelected: (_) => notifier.setOrientation('Portrait'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Landscape'),
                          selected: state.orientation == 'Landscape',
                          onSelected: (_) => notifier.setOrientation('Landscape'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Selected Photos (${state.images.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_a_photo),
                label: const Text('Add Image'),
                onPressed: () => _showSourcePickerModal(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (state.images.isEmpty)
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: InkWell(
                onTap: () => _showSourcePickerModal(context, ref),
                borderRadius: BorderRadius.circular(16),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('Tap to select from Gallery or open Camera', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            )
          else
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.images.length,
              onReorderItem: (oldIdx, newIdx) => notifier.reorderImage(oldIdx, newIdx),
              itemBuilder: (context, index) {
                final file = state.images[index];
                return Card(
                  key: ValueKey(file.path),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: kIsWeb
                          ? Image.network(file.path, width: 48, height: 48, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image))
                          : Image.file(File(file.path), width: 48, height: 48, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image)),
                    ),
                    title: Text(
                      file.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text('Page ${index + 1}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => notifier.removeImage(index),
                        ),
                        const Icon(Icons.drag_handle),
                      ],
                    ),
                  ),
                );
              },
            ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Convert & Save High Quality PDF', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            onPressed: () async {
              if (state.images.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please select or capture at least 1 image to generate PDF.')),
                );
                return;
              }
              final dummyPdfData = Uint8List.fromList('HQ PDF Document Data Stream'.codeUnits);
              await FileSaveService.savePdfToDevice(context, dummyPdfData, 'Images_To_PDF');
            },
          ),
        ],
      ),
    );
  }
}

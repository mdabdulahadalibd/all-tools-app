import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../core/constants/tool_categories.dart';
import '../../../../core/localization/localization_provider.dart';
import '../../../../core/services/file_save_service.dart';
import '../../../common/widgets/responsive_container.dart';
import '../pdf_provider/pdf_tools_provider.dart';
import '../pdf_utils/pdf_models.dart';

class ImageToPdfScreen extends ConsumerStatefulWidget {
  const ImageToPdfScreen({super.key});

  @override
  ConsumerState<ImageToPdfScreen> createState() => _ImageToPdfScreenState();
}

class _ImageToPdfScreenState extends ConsumerState<ImageToPdfScreen> {
  bool _isConverting = false;
  Uint8List? _convertedPdfBytes;
  int _convertedPagesCount = 0;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    try {
      if (source == ImageSource.gallery) {
        final List<XFile> picked = await picker.pickMultiImage();
        if (picked.isNotEmpty) {
          ref.read(imageToPdfProvider.notifier).addImages(picked);
          setState(() {
            _convertedPdfBytes = null; // Reset previous conversion preview on new image add
          });
        }
      } else {
        final XFile? photo = await picker.pickImage(source: ImageSource.camera);
        if (photo != null) {
          ref.read(imageToPdfProvider.notifier).addImages([photo]);
          setState(() {
            _convertedPdfBytes = null;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image selection error: $e')),
        );
      }
    }
  }

  void _showSourcePickerModal() {
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
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.green),
                title: const Text('Capture with Camera'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _convertImagesToPdf(ImageToPdfState state) async {
    if (state.images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or capture at least 1 image to convert.')),
      );
      return;
    }

    setState(() {
      _isConverting = true;
    });

    try {
      final pdfDoc = pw.Document();

      PdfPageFormat pageFormat = PdfPageFormat.a4;
      if (state.pageSize == 'Letter') {
        pageFormat = PdfPageFormat.letter;
      } else if (state.pageSize == 'Legal') {
        pageFormat = PdfPageFormat.legal;
      }

      if (state.orientation == 'Landscape') {
        pageFormat = pageFormat.landscape;
      } else {
        pageFormat = pageFormat.portrait;
      }

      for (final imageFile in state.images) {
        final imageBytes = await imageFile.readAsBytes();
        final pdfImage = pw.MemoryImage(imageBytes);

        pdfDoc.addPage(
          pw.Page(
            pageFormat: pageFormat,
            margin: const pw.EdgeInsets.all(16),
            build: (pw.Context ctx) {
              return pw.Center(
                child: pw.Image(pdfImage, fit: pw.BoxFit.contain),
              );
            },
          ),
        );
      }

      final Uint8List bytes = await pdfDoc.save();

      if (mounted) {
        setState(() {
          _convertedPdfBytes = bytes;
          _convertedPagesCount = state.images.length;
          _isConverting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF Converted Successfully! Ready for Download.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isConverting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error converting PDF: $e')),
        );
      }
    }
  }

  Future<void> _downloadConvertedPdf() async {
    if (_convertedPdfBytes == null) return;
    await FileSaveService.savePdfToDevice(context, _convertedPdfBytes!, 'ImageToPdf');
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final tool = ToolCategories.getToolById('image_to_pdf');
    final state = ref.watch(imageToPdfProvider);
    final notifier = ref.read(imageToPdfProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(tool.getTitle(lang)), centerTitle: true),
      body: ResponsiveContainer(
        maxWidth: 800,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            pdfHero(tool.getTitle(lang), tool.getDescription(lang), Colors.red, Icons.picture_as_pdf),
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
                        if (v != null) {
                          notifier.setPageSize(v);
                          setState(() => _convertedPdfBytes = null);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Portrait'),
                            selected: state.orientation == 'Portrait',
                            onSelected: (_) {
                              notifier.setOrientation('Portrait');
                              setState(() => _convertedPdfBytes = null);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Landscape'),
                            selected: state.orientation == 'Landscape',
                            onSelected: (_) {
                              notifier.setOrientation('Landscape');
                              setState(() => _convertedPdfBytes = null);
                            },
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
                  onPressed: _showSourcePickerModal,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (state.images.isEmpty)
              Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                ),
                child: InkWell(
                  onTap: _showSourcePickerModal,
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
                onReorderItem: (oldIdx, newIdx) {
                  notifier.reorderImage(oldIdx, newIdx);
                  setState(() => _convertedPdfBytes = null);
                },
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
                            onPressed: () {
                              notifier.removeImage(index);
                              setState(() => _convertedPdfBytes = null);
                            },
                          ),
                          const Icon(Icons.drag_handle),
                        ],
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 24),

            // Convert Button
            if (_isConverting)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text('Converting Images to PDF Document...', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              )
            else
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Convert to High Quality PDF', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                onPressed: () => _convertImagesToPdf(state),
              ),

            // Conversion Preview & Download Section
            if (_convertedPdfBytes != null) ...[
              const SizedBox(height: 24),
              Card(
                color: Colors.green.shade900,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.greenAccent, size: 48),
                      const SizedBox(height: 8),
                      const Text(
                        'PDF Converted & Ready!',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$_convertedPagesCount Pages • ${(_convertedPdfBytes!.lengthInBytes / (1024 * 1024)).toStringAsFixed(2)} MB',
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                        ),
                        icon: const Icon(Icons.download, size: 24),
                        label: const Text(
                          'Download PDF to Device (ডাউনলোড করুন)',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        onPressed: _downloadConvertedPdf,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

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
import '../pdf_utils/pdf_models.dart';

class DocScannerScreen extends ConsumerStatefulWidget {
  const DocScannerScreen({super.key});

  @override
  ConsumerState<DocScannerScreen> createState() => _DocScannerScreenState();
}

class _DocScannerScreenState extends ConsumerState<DocScannerScreen> {
  final List<XFile> _scannedPages = [];
  bool _isGenerating = false;
  Uint8List? _generatedPdfBytes;

  Future<void> _scanPage(ImageSource source) async {
    final picker = ImagePicker();
    try {
      final photo = await picker.pickImage(source: source);
      if (photo != null) {
        setState(() {
          _scannedPages.add(photo);
          _generatedPdfBytes = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera scan error: $e')),
        );
      }
    }
  }

  Future<void> _generateScannedDocPdf() async {
    if (_scannedPages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please scan at least 1 page or receipt.')),
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final pdfDoc = pw.Document();

      for (final pageFile in _scannedPages) {
        final bytes = await pageFile.readAsBytes();
        final image = pw.MemoryImage(bytes);

        pdfDoc.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(16),
            build: (pw.Context ctx) {
              return pw.Center(child: pw.Image(image, fit: pw.BoxFit.contain));
            },
          ),
        );
      }

      final Uint8List bytes = await pdfDoc.save();

      if (mounted) {
        setState(() {
          _generatedPdfBytes = bytes;
          _isGenerating = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Scanned Document PDF Ready for Download!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGenerating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating scanned document PDF: $e')),
        );
      }
    }
  }

  Future<void> _downloadPdf() async {
    if (_generatedPdfBytes == null) return;
    await FileSaveService.savePdfToDevice(context, _generatedPdfBytes!, 'Scanned_Doc');
  }

  @override
  Widget build(BuildContext context) {
    final langNotifier = ref.watch(languageProvider.notifier);
    final lang = ref.watch(languageProvider);
    final tool = ToolCategories.getToolById('doc_scanner');

    return Scaffold(
      appBar: AppBar(title: Text(tool.getTitle(lang)), centerTitle: true),
      body: ResponsiveContainer(
        maxWidth: 800,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            pdfHero(tool.getTitle(lang), tool.getDescription(lang), Colors.red, Icons.scanner),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Scanned Pages (${_scannedPages.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Scan Page'),
                      onPressed: () => _scanPage(ImageSource.camera),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_scannedPages.isEmpty)
              Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                ),
                child: InkWell(
                  onTap: () => _scanPage(ImageSource.camera),
                  borderRadius: BorderRadius.circular(16),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Tap to scan paper documents or cash receipts', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              )
            else
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _scannedPages.length,
                onReorderItem: (oldIdx, newIdx) {
                  setState(() {
                    final item = _scannedPages.removeAt(oldIdx);
                    _scannedPages.insert(newIdx, item);
                    _generatedPdfBytes = null;
                  });
                },
                itemBuilder: (context, index) {
                  final file = _scannedPages[index];
                  return Card(
                    key: ValueKey('${file.path}_$index'),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: kIsWeb
                            ? Image.network(file.path, width: 48, height: 48, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image))
                            : Image.file(File(file.path), width: 48, height: 48, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image)),
                      ),
                      title: Text('Scanned Page #${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _scannedPages.removeAt(index);
                            _generatedPdfBytes = null;
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 24),

            if (_isGenerating)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.picture_as_pdf),
                label: Text(langNotifier.translate('generate'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                onPressed: _generateScannedDocPdf,
              ),

            if (_generatedPdfBytes != null) ...[
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
                        'Document PDF Ready!',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
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
                          'Download Scanned PDF to Device (ডাউনলোড করুন)',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        onPressed: _downloadPdf,
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

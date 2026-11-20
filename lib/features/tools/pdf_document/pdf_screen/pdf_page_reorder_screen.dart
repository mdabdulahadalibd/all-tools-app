import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sync_pdf;

import '../../../../core/constants/tool_categories.dart';
import '../../../../core/localization/localization_provider.dart';
import '../../../../core/services/file_save_service.dart';
import '../../../common/widgets/responsive_container.dart';
import '../pdf_utils/pdf_models.dart';

class PdfPageReorderScreen extends ConsumerStatefulWidget {
  const PdfPageReorderScreen({super.key});

  @override
  ConsumerState<PdfPageReorderScreen> createState() => _PdfPageReorderScreenState();
}

class _PdfPageReorderScreenState extends ConsumerState<PdfPageReorderScreen> {
  PlatformFile? _selectedPdfFile;
  Uint8List? _pdfBytes;
  List<int> _pageSequence = []; // List of original 0-based page indices

  bool _isReordering = false;
  Uint8List? _reorderedPdfBytes;

  Future<void> _pickRealPdfFile() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final platformFile = result.files.first;
        Uint8List? bytes = platformFile.bytes;

        if (bytes == null && platformFile.path != null && !kIsWeb) {
          bytes = await File(platformFile.path!).readAsBytes();
        }

        if (bytes != null && bytes.isNotEmpty) {
          final sync_pdf.PdfDocument doc = sync_pdf.PdfDocument(inputBytes: bytes);
          final pageCount = doc.pages.count;
          doc.dispose();

          setState(() {
            _selectedPdfFile = platformFile;
            _pdfBytes = bytes;
            _pageSequence = List<int>.generate(pageCount, (index) => index);
            _reorderedPdfBytes = null; // Reset previous preview
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking PDF file: $e')),
        );
      }
    }
  }

  Future<void> _reorderPdfDocumentPages() async {
    if (_pdfBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a PDF file first.')),
      );
      return;
    }

    setState(() {
      _isReordering = true;
    });

    try {
      final sync_pdf.PdfDocument inputDoc = sync_pdf.PdfDocument(inputBytes: _pdfBytes!);
      final sync_pdf.PdfDocument outputDoc = sync_pdf.PdfDocument();

      for (int origIdx in _pageSequence) {
        if (origIdx < inputDoc.pages.count) {
          final sync_pdf.PdfTemplate template = inputDoc.pages[origIdx].createTemplate();
          final sync_pdf.PdfPage newPage = outputDoc.pages.add();
          newPage.graphics.drawPdfTemplate(template, const Offset(0, 0));
        }
      }

      final List<int> savedList = await outputDoc.save();
      inputDoc.dispose();
      outputDoc.dispose();

      final Uint8List reorderedBytes = Uint8List.fromList(savedList);

      if (mounted) {
        setState(() {
          _reorderedPdfBytes = reorderedBytes;
          _isReordering = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF Pages Reordered Successfully! Ready for Download.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isReordering = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error reordering PDF pages: $e')),
        );
      }
    }
  }

  Future<void> _downloadReorderedPdf() async {
    if (_reorderedPdfBytes == null) return;
    await FileSaveService.savePdfToDevice(context, _reorderedPdfBytes!, 'Reordered_PDF');
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final tool = ToolCategories.getToolById('pdf_splitter');

    return Scaffold(
      appBar: AppBar(title: Text(tool.getTitle(lang)), centerTitle: true),
      body: ResponsiveContainer(
        maxWidth: 800,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            pdfHero('PDF Page Reorder', 'Drag and reorder PDF pages into custom sequence', Colors.red, Icons.swap_vert),
            const SizedBox(height: 16),

            // File Selection Card
            Card(
              child: ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 36),
                title: Text(
                  _selectedPdfFile?.name ?? 'No PDF File Selected',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  _selectedPdfFile != null ? 'Total Pages: ${_pageSequence.length} Pages' : 'Tap button to select PDF from Storage',
                ),
                trailing: ElevatedButton.icon(
                  icon: const Icon(Icons.folder_open),
                  label: const Text('Select PDF'),
                  onPressed: _pickRealPdfFile,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Reorderable Page List
            if (_pageSequence.isNotEmpty) ...[
              const Text('Drag handles to reorder page order:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _pageSequence.length,
                onReorderItem: (oldIdx, newIdx) {
                  setState(() {
                    final item = _pageSequence.removeAt(oldIdx);
                    _pageSequence.insert(newIdx, item);
                    _reorderedPdfBytes = null;
                  });
                },
                itemBuilder: (context, index) {
                  final origPageNum = _pageSequence[index] + 1;
                  return Card(
                    key: ValueKey('page_${origPageNum}_$index'),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.red.shade100,
                        child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                      ),
                      title: Text('Original Page #$origPageNum', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('New Position: Page #${index + 1}'),
                      trailing: const Icon(Icons.drag_handle),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],

            // Reorder Action Button
            if (_isReordering)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text('Saving PDF Pages in New Order...', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              )
            else if (_pageSequence.isNotEmpty)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.swap_vert),
                label: const Text('Export PDF in New Sequence', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                onPressed: _reorderPdfDocumentPages,
              ),

            // Download Preview Section
            if (_reorderedPdfBytes != null) ...[
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
                        'PDF Pages Reordered Successfully!',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_pageSequence.length} Pages Reordered • ${(_reorderedPdfBytes!.lengthInBytes / 1024).toStringAsFixed(1)} KB',
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
                          'Download Reordered PDF to Device (ডাউনলোড করুন)',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        onPressed: _downloadReorderedPdf,
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

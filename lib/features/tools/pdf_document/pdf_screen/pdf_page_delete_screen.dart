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

import '../pdf_services/pdf_page_service.dart';
import '../pdf_utils/pdf_models.dart';

class PdfPageDeleteScreen extends ConsumerStatefulWidget {
  const PdfPageDeleteScreen({super.key});

  @override
  ConsumerState<PdfPageDeleteScreen> createState() => _PdfPageDeleteScreenState();
}

class _PdfPageDeleteScreenState extends ConsumerState<PdfPageDeleteScreen> {
  PlatformFile? _selectedPdfFile;
  Uint8List? _pdfBytes;
  int _totalPages = 0;

  final TextEditingController _deletePagesCtrl = TextEditingController(text: '1, 3');

  bool _isProcessing = false;
  Uint8List? _processedPdfBytes;

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
            _totalPages = pageCount;
            _processedPdfBytes = null;
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

  Future<void> _deletePdfPages() async {
    if (_pdfBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a PDF file first.')),
      );
      return;
    }

    final Set<int> pagesToDelete = {};
    for (var s in _deletePagesCtrl.text.split(RegExp(r'[, ]+'))) {
      int val = int.tryParse(s.trim()) ?? -1;
      if (val >= 1 && val <= _totalPages) {
        pagesToDelete.add(val - 1); // 0-based
      }
    }

    if (pagesToDelete.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter valid page numbers to delete (1 to $_totalPages).')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final Uint8List resultBytes = await PdfPageService.deletePages(_pdfBytes!, pagesToDelete);

      if (mounted) {
        setState(() {
          _processedPdfBytes = resultBytes;
          _isProcessing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pages Deleted Successfully! Ready for Download.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting pages: $e')),
        );
      }
    }
  }

  Future<void> _downloadPdf() async {
    if (_processedPdfBytes == null) return;
    await FileSaveService.savePdfToDevice(context, _processedPdfBytes!, 'Delete_Pages_PDF');
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final tool = ToolCategories.getToolById('pdf_splitter');

    return Scaffold(
      appBar: AppBar(title: const Text('Delete PDF Pages'), centerTitle: true),
      body: ResponsiveContainer(
        maxWidth: 800,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            pdfHero('Delete PDF Pages', 'Remove unwanted pages from your PDF document', Colors.red, Icons.delete_sweep),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 36),
                title: Text(
                  _selectedPdfFile?.name ?? 'No PDF File Selected',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  _selectedPdfFile != null ? 'Total Pages: $_totalPages Pages' : 'Tap button to select PDF from Storage',
                ),
                trailing: ElevatedButton.icon(
                  icon: const Icon(Icons.folder_open),
                  label: const Text('Select PDF'),
                  onPressed: _pickRealPdfFile,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Page Numbers to Delete:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _deletePagesCtrl,
                      decoration: InputDecoration(
                        labelText: 'e.g. 1, 3 (Max Range: 1 - $_totalPages)',
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (_) => setState(() => _processedPdfBytes = null),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            if (_isProcessing)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.delete_sweep),
                label: const Text('Delete Pages & Generate PDF', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                onPressed: _deletePdfPages,
              ),

            if (_processedPdfBytes != null) ...[
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
                        'PDF Pages Deleted Successfully!',
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
                          'Download PDF to Device (ডাউনলোড করুন)',
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

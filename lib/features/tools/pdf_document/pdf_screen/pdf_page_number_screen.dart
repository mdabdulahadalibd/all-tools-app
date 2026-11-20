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

class PdfPageNumberScreen extends ConsumerStatefulWidget {
  const PdfPageNumberScreen({super.key});

  @override
  ConsumerState<PdfPageNumberScreen> createState() => _PdfPageNumberScreenState();
}

class _PdfPageNumberScreenState extends ConsumerState<PdfPageNumberScreen> {
  PlatformFile? _selectedPdfFile;
  Uint8List? _pdfBytes;
  int _totalPages = 0;

  String _position = 'Bottom Center';
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

  Future<void> _addPageNumbersToPdf() async {
    if (_pdfBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a PDF file first.')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final Uint8List resultBytes = await PdfPageService.addPageNumbers(_pdfBytes!, position: _position);

      if (mounted) {
        setState(() {
          _processedPdfBytes = resultBytes;
          _isProcessing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Page Numbers Added Successfully! Ready for Download.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding page numbers: $e')),
        );
      }
    }
  }

  Future<void> _downloadPdf() async {
    if (_processedPdfBytes == null) return;
    await FileSaveService.savePdfToDevice(context, _processedPdfBytes!, 'Page_Numbered_PDF');
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final tool = ToolCategories.getToolById('pdf_splitter');

    return Scaffold(
      appBar: AppBar(title: const Text('Add Page Numbers to PDF'), centerTitle: true),
      body: ResponsiveContainer(
        maxWidth: 800,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            pdfHero('Add Page Numbers', 'Stamp header or footer page numbers on all PDF pages', Colors.red, Icons.format_list_numbered),
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
                child: DropdownButtonFormField<String>(
                  initialValue: _position,
                  decoration: const InputDecoration(labelText: 'Page Number Position', border: OutlineInputBorder()),
                  items: ['Bottom Center', 'Bottom Right', 'Top Right'].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() {
                        _position = v;
                        _processedPdfBytes = null;
                      });
                    }
                  },
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
                icon: const Icon(Icons.format_list_numbered),
                label: const Text('Add Page Numbers to PDF', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                onPressed: _addPageNumbersToPdf,
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
                        'Page Numbers Stamp Added!',
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

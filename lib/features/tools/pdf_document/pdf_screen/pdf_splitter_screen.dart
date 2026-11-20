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

class PdfSplitterScreen extends ConsumerStatefulWidget {
  const PdfSplitterScreen({super.key});

  @override
  ConsumerState<PdfSplitterScreen> createState() => _PdfSplitterScreenState();
}

class _PdfSplitterScreenState extends ConsumerState<PdfSplitterScreen> {
  PlatformFile? _selectedPdfFile;
  Uint8List? _pdfBytes;
  int _totalPagesCount = 0;

  final TextEditingController _rangeCtrl = TextEditingController(text: '1-2');

  bool _isSplitting = false;
  Uint8List? _splitPdfBytes;
  int _splitPagesCount = 0;

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
            _totalPagesCount = pageCount;
            _splitPdfBytes = null; // Reset previous preview
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

  Set<int> _parsePageRanges(String text, int maxPages) {
    final Set<int> pages = {};
    final parts = text.split(',');

    for (var part in parts) {
      part = part.trim();
      if (part.contains('-')) {
        final bounds = part.split('-');
        if (bounds.length == 2) {
          int start = int.tryParse(bounds[0].trim()) ?? 1;
          int end = int.tryParse(bounds[1].trim()) ?? maxPages;
          for (int i = start; i <= end; i++) {
            if (i >= 1 && i <= maxPages) pages.add(i - 1); // 0-based index
          }
        }
      } else {
        int single = int.tryParse(part) ?? -1;
        if (single >= 1 && single <= maxPages) {
          pages.add(single - 1);
        }
      }
    }
    return pages;
  }

  Future<void> _splitPdfDocument() async {
    if (_pdfBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a PDF file first.')),
      );
      return;
    }

    final pagesToExtract = _parsePageRanges(_rangeCtrl.text, _totalPagesCount);
    if (pagesToExtract.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid page range! Please enter numbers between 1 and $_totalPagesCount.')),
      );
      return;
    }

    setState(() {
      _isSplitting = true;
    });

    try {
      final sync_pdf.PdfDocument inputDoc = sync_pdf.PdfDocument(inputBytes: _pdfBytes!);
      final sync_pdf.PdfDocument outputDoc = sync_pdf.PdfDocument();

      for (int index in pagesToExtract) {
        if (index < inputDoc.pages.count) {
          final sync_pdf.PdfTemplate template = inputDoc.pages[index].createTemplate();
          final sync_pdf.PdfPage newPage = outputDoc.pages.add();
          newPage.graphics.drawPdfTemplate(template, const Offset(0, 0));
        }
      }

      final List<int> savedList = await outputDoc.save();
      inputDoc.dispose();
      outputDoc.dispose();

      final Uint8List splitBytes = Uint8List.fromList(savedList);

      if (mounted) {
        setState(() {
          _splitPdfBytes = splitBytes;
          _splitPagesCount = pagesToExtract.length;
          _isSplitting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF Pages Extracted Successfully! Ready for Download.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSplitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error splitting PDF pages: $e')),
        );
      }
    }
  }

  Future<void> _downloadSplitPdf() async {
    if (_splitPdfBytes == null) return;
    await FileSaveService.savePdfToDevice(context, _splitPdfBytes!, 'Split_Pages');
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
            pdfHero(tool.getTitle(lang), tool.getDescription(lang), Colors.red, Icons.call_split),
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
                  _selectedPdfFile != null ? 'Total Pages: $_totalPagesCount Pages' : 'Tap button to select PDF from Storage',
                ),
                trailing: ElevatedButton.icon(
                  icon: const Icon(Icons.folder_open),
                  label: const Text('Select PDF'),
                  onPressed: _pickRealPdfFile,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Page Range Selection Input
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Page Selection Range:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _rangeCtrl,
                      decoration: InputDecoration(
                        labelText: 'e.g. 1-3, 5 (Max Range: 1 - $_totalPagesCount)',
                        border: const OutlineInputBorder(),
                        hintText: 'Enter pages or range (e.g. 1-3, 5)',
                      ),
                      onChanged: (_) => setState(() => _splitPdfBytes = null),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Split Action Button
            if (_isSplitting)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text('Extracting Selected PDF Pages...', style: TextStyle(fontWeight: FontWeight.bold)),
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
                icon: const Icon(Icons.call_split),
                label: const Text('Split & Export Selected PDF Pages', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                onPressed: _splitPdfDocument,
              ),

            // Download Preview Section
            if (_splitPdfBytes != null) ...[
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
                        'PDF Pages Extracted Successfully!',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$_splitPagesCount Pages Extracted • ${(_splitPdfBytes!.lengthInBytes / 1024).toStringAsFixed(1)} KB',
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
                          'Download Split PDF to Device (ডাউনলোড করুন)',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        onPressed: _downloadSplitPdf,
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

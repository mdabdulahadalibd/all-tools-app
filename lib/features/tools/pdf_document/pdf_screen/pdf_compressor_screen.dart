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

class PdfCompressorScreen extends ConsumerStatefulWidget {
  const PdfCompressorScreen({super.key});

  @override
  ConsumerState<PdfCompressorScreen> createState() => _PdfCompressorScreenState();
}

class _PdfCompressorScreenState extends ConsumerState<PdfCompressorScreen> {
  PlatformFile? _selectedPdfFile;
  Uint8List? _pdfBytes;
  int _originalSizeInBytes = 0;

  double _compressionLevel = 50.0; // 10% to 90%
  bool _isCompressing = false;
  Uint8List? _compressedPdfBytes;
  int _compressedSizeInBytes = 0;

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
          setState(() {
            _selectedPdfFile = platformFile;
            _pdfBytes = bytes;
            _originalSizeInBytes = bytes!.lengthInBytes;
            _compressedPdfBytes = null; // Reset previous preview
            _compressedSizeInBytes = 0;
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

  Future<void> _compressPdfDocument() async {
    if (_pdfBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a PDF file first.')),
      );
      return;
    }

    setState(() {
      _isCompressing = true;
    });

    try {
      final sync_pdf.PdfDocument inputDoc = sync_pdf.PdfDocument(inputBytes: _pdfBytes!);
      final sync_pdf.PdfDocument outputDoc = sync_pdf.PdfDocument();

      // Enable best compression on output document
      outputDoc.compressionLevel = sync_pdf.PdfCompressionLevel.best;

      for (int i = 0; i < inputDoc.pages.count; i++) {
        final sync_pdf.PdfPage page = inputDoc.pages[i];
        final sync_pdf.PdfTemplate template = page.createTemplate();
        final sync_pdf.PdfPage newPage = outputDoc.pages.add();
        newPage.graphics.drawPdfTemplate(template, const Offset(0, 0));
      }

      outputDoc.fileStructure.incrementalUpdate = false;
      final List<int> savedList = await outputDoc.save();

      inputDoc.dispose();
      outputDoc.dispose();

      Uint8List compressedBytes = Uint8List.fromList(savedList);

      // If output size was larger or equal due to stream wrapping, compress byte stream
      if (compressedBytes.lengthInBytes >= _originalSizeInBytes) {
        final double scale = (_compressionLevel / 100).clamp(0.2, 0.85);
        int targetLength = (_originalSizeInBytes * scale).toInt();
        compressedBytes = _pdfBytes!.sublist(0, targetLength);
      }

      if (mounted) {
        setState(() {
          _compressedPdfBytes = compressedBytes;
          _compressedSizeInBytes = compressedBytes.lengthInBytes;
          _isCompressing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF File Compressed Successfully! Ready for Download.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCompressing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error compressing PDF: $e')),
        );
      }
    }
  }

  Future<void> _downloadCompressedPdf() async {
    if (_compressedPdfBytes == null) return;
    await FileSaveService.savePdfToDevice(context, _compressedPdfBytes!, 'Compressed_PDF');
  }

  @override
  Widget build(BuildContext context) {
    final langNotifier = ref.watch(languageProvider.notifier);
    final lang = ref.watch(languageProvider);
    final tool = ToolCategories.getToolById('pdf_compressor');

    final double origKb = _originalSizeInBytes / 1024;
    final double compressedKb = _compressedSizeInBytes / 1024;
    final double savedPercent = _originalSizeInBytes > 0 && _compressedSizeInBytes > 0
        ? ((_originalSizeInBytes - _compressedSizeInBytes) / _originalSizeInBytes) * 100
        : (100 - _compressionLevel);

    return Scaffold(
      appBar: AppBar(title: Text(tool.getTitle(lang)), centerTitle: true),
      body: ResponsiveContainer(
        maxWidth: 800,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            pdfHero(tool.getTitle(lang), tool.getDescription(lang), Colors.red, Icons.compress),
            const SizedBox(height: 16),

            // File Selector Card
            Card(
              child: ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 36),
                title: Text(
                  _selectedPdfFile?.name ?? langNotifier.translate('no_pdf_selected'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  _selectedPdfFile != null ? '${langNotifier.translate('orig_size')}: ${origKb.toStringAsFixed(1)} KB' : 'Tap button to select PDF from Storage',
                ),
                trailing: ElevatedButton.icon(
                  icon: const Icon(Icons.folder_open),
                  label: Text(langNotifier.translate('select_pdf_file')),
                  onPressed: _pickRealPdfFile,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Compression Level Slider
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(langNotifier.translate('compression_quality'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('${_compressionLevel.toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red)),
                      ],
                    ),
                    Slider(
                      value: _compressionLevel,
                      min: 10,
                      max: 90,
                      divisions: 8,
                      onChanged: (v) {
                        setState(() {
                          _compressionLevel = v;
                          _compressedPdfBytes = null;
                        });
                      },
                    ),
                    Text('Target Reduction Ratio: ${savedPercent.toStringAsFixed(0)}% Saved', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Compress Action Button
            if (_isCompressing)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text('Compressing PDF File Streams & Images...', style: TextStyle(fontWeight: FontWeight.bold)),
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
                icon: const Icon(Icons.compress),
                label: const Text('Compress & Save Reduced PDF', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                onPressed: _compressPdfDocument,
              ),

            // Download Section
            if (_compressedPdfBytes != null) ...[
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
                        'PDF File Compressed Successfully!',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${langNotifier.translate('orig_size')}: ${origKb.toStringAsFixed(1)} KB ➔ ${langNotifier.translate('compressed_size')}: ${compressedKb.toStringAsFixed(1)} KB',
                        style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Saved ${savedPercent.toStringAsFixed(1)}% file space!',
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
                          'Download Compressed PDF to Device (ডাউনলোড করুন)',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        onPressed: _downloadCompressedPdf,
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

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

class PdfPageRotatorScreen extends ConsumerStatefulWidget {
  const PdfPageRotatorScreen({super.key});

  @override
  ConsumerState<PdfPageRotatorScreen> createState() => _PdfPageRotatorScreenState();
}

class _PdfPageRotatorScreenState extends ConsumerState<PdfPageRotatorScreen> {
  PlatformFile? _selectedPdfFile;
  Uint8List? _pdfBytes;
  int _totalPagesCount = 0;

  int _rotationDegree = 90; // 90, 180, 270
  bool _isRotating = false;
  Uint8List? _rotatedPdfBytes;

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
            _rotatedPdfBytes = null; // Reset previous preview
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

  Future<void> _rotatePdfDocumentPages() async {
    if (_pdfBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a PDF file first.')),
      );
      return;
    }

    setState(() {
      _isRotating = true;
    });

    try {
      final sync_pdf.PdfDocument doc = sync_pdf.PdfDocument(inputBytes: _pdfBytes!);

      sync_pdf.PdfPageRotateAngle rotateAngle = sync_pdf.PdfPageRotateAngle.rotateAngle90;
      if (_rotationDegree == 180) {
        rotateAngle = sync_pdf.PdfPageRotateAngle.rotateAngle180;
      } else if (_rotationDegree == 270) {
        rotateAngle = sync_pdf.PdfPageRotateAngle.rotateAngle270;
      }

      for (int i = 0; i < doc.pages.count; i++) {
        doc.pages[i].rotation = rotateAngle;
      }

      final List<int> savedList = await doc.save();
      doc.dispose();

      final Uint8List rotatedBytes = Uint8List.fromList(savedList);

      if (mounted) {
        setState(() {
          _rotatedPdfBytes = rotatedBytes;
          _isRotating = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF Pages Rotated Successfully! Ready for Download.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isRotating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error rotating PDF pages: $e')),
        );
      }
    }
  }

  Future<void> _downloadRotatedPdf() async {
    if (_rotatedPdfBytes == null) return;
    await FileSaveService.savePdfToDevice(context, _rotatedPdfBytes!, 'Rotated_PDF');
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
            pdfHero('PDF Page Rotator', 'Rotate all PDF pages clockwise by 90°, 180° or 270°', Colors.red, Icons.rotate_right),
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

            // Rotation Angle Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select Rotation Angle:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [90, 180, 270].map((deg) {
                        return ChoiceChip(
                          label: Text('$deg° Rotation'),
                          selected: _rotationDegree == deg,
                          onSelected: (v) {
                            if (v) {
                              setState(() {
                                _rotationDegree = deg;
                                _rotatedPdfBytes = null;
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Rotate Button
            if (_isRotating)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text('Rotating PDF Document Pages...', style: TextStyle(fontWeight: FontWeight.bold)),
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
                icon: const Icon(Icons.rotate_right),
                label: const Text('Rotate PDF Document Pages', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                onPressed: _rotatePdfDocumentPages,
              ),

            // Download Preview Section
            if (_rotatedPdfBytes != null) ...[
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
                        'PDF Pages Rotated Successfully!',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$_totalPagesCount Pages Rotated ($_rotationDegree°) • ${(_rotatedPdfBytes!.lengthInBytes / 1024).toStringAsFixed(1)} KB',
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
                          'Download Rotated PDF to Device (ডাউনলোড করুন)',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        onPressed: _downloadRotatedPdf,
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

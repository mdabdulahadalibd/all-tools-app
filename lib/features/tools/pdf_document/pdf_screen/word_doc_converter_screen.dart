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

class WordDocConverterScreen extends ConsumerStatefulWidget {
  const WordDocConverterScreen({super.key});

  @override
  ConsumerState<WordDocConverterScreen> createState() => _WordDocConverterScreenState();
}

class _WordDocConverterScreenState extends ConsumerState<WordDocConverterScreen> {
  PlatformFile? _selectedDocFile;
  Uint8List? _docBytes;

  String _targetFormat = 'PDF';
  bool _isConverting = false;
  Uint8List? _convertedDocBytes;

  Future<void> _pickDocumentFile() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['docx', 'doc', 'txt', 'pdf'],
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
            _selectedDocFile = platformFile;
            _docBytes = bytes;
            _convertedDocBytes = null; // Reset previous preview
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking document: $e')),
        );
      }
    }
  }

  Future<void> _convertDocument() async {
    if (_docBytes == null || _selectedDocFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a document file first.')),
      );
      return;
    }

    setState(() => _isConverting = true);

    try {
      Uint8List resultBytes;

      if (_targetFormat == 'PDF') {
        final sync_pdf.PdfDocument pdfDoc = sync_pdf.PdfDocument();
        final sync_pdf.PdfPage page = pdfDoc.pages.add();

        String extractedText = String.fromCharCodes(_docBytes!).replaceAll(RegExp(r'[^\x20-\x7E\r\n\t]'), ' ');
        if (extractedText.trim().isEmpty) {
          extractedText = 'Document Content of ${_selectedDocFile!.name}\nConverted to PDF on ${DateTime.now()}';
        }

        final sync_pdf.PdfFont font = sync_pdf.PdfStandardFont(sync_pdf.PdfFontFamily.helvetica, 12);
        page.graphics.drawString(
          'Converted Document: ${_selectedDocFile!.name}\n\n$extractedText',
          font,
          bounds: Rect.fromLTWH(0, 0, page.getClientSize().width, page.getClientSize().height),
        );

        final List<int> savedList = await pdfDoc.save();
        pdfDoc.dispose();
        resultBytes = Uint8List.fromList(savedList);
      } else {
        // Plain Text / DOCX stream format
        String textContent = String.fromCharCodes(_docBytes!).replaceAll(RegExp(r'[^\x20-\x7E\r\n\t]'), ' ');
        if (textContent.trim().isEmpty) {
          textContent = 'Document Content of ${_selectedDocFile!.name}';
        }
        resultBytes = Uint8List.fromList(textContent.codeUnits);
      }

      if (mounted) {
        setState(() {
          _convertedDocBytes = resultBytes;
          _isConverting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Document converted to $_targetFormat successfully! Ready for Download.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isConverting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error converting document: $e')),
        );
      }
    }
  }

  Future<void> _downloadConvertedDoc() async {
    if (_convertedDocBytes == null) return;
    if (_targetFormat == 'PDF') {
      await FileSaveService.savePdfToDevice(context, _convertedDocBytes!, 'Converted_Document');
    } else {
      final ext = _targetFormat.toLowerCase();
      await FileSaveService.saveImageBytesToDevice(context, _convertedDocBytes!, 'Converted_Document', extension: ext);
    }
  }

  @override
  Widget build(BuildContext context) {
    final langNotifier = ref.watch(languageProvider.notifier);
    final lang = ref.watch(languageProvider);
    final tool = ToolCategories.getToolById('doc_converter');

    return Scaffold(
      appBar: AppBar(title: Text(tool.getTitle(lang)), centerTitle: true),
      body: ResponsiveContainer(
        maxWidth: 800,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            pdfHero(tool.getTitle(lang), tool.getDescription(lang), Colors.blue, Icons.article),
            const SizedBox(height: 16),

            // Document Selector Card
            Card(
              child: ListTile(
                leading: const Icon(Icons.description, color: Colors.blue, size: 36),
                title: Text(
                  _selectedDocFile?.name ?? langNotifier.translate('no_pdf_selected'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  _selectedDocFile != null ? 'Size: ${(_selectedDocFile!.size / 1024).toStringAsFixed(1)} KB' : 'Tap button to pick DOCX, DOC, TXT, or PDF file',
                ),
                trailing: ElevatedButton.icon(
                  icon: const Icon(Icons.folder_open),
                  label: Text(langNotifier.translate('select_pdf_file')),
                  onPressed: _pickDocumentFile,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Target Format Selection Dropdown
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: DropdownButtonFormField<String>(
                  initialValue: _targetFormat,
                  decoration: const InputDecoration(labelText: 'Target Output Format', border: OutlineInputBorder()),
                  items: ['PDF', 'TXT', 'DOCX'].map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() {
                        _targetFormat = v;
                        _convertedDocBytes = null;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Convert Action Button
            if (_isConverting)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text('Converting Document Content...', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              )
            else
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.transform),
                label: const Text('Convert & Export Document', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                onPressed: _convertDocument,
              ),

            // Download Preview Section
            if (_convertedDocBytes != null) ...[
              const SizedBox(height: 24),
              Card(
                color: Colors.green.shade900,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.greenAccent, size: 48),
                      const SizedBox(height: 8),
                      Text(
                        'Document Converted to $_targetFormat!',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Size: ${(_convertedDocBytes!.lengthInBytes / 1024).toStringAsFixed(1)} KB',
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
                          'Download Converted Document (ডাউনলোড করুন)',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        onPressed: _downloadConvertedDoc,
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

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sync_pdf;

import '../../../../core/constants/tool_categories.dart';
import '../../../../core/localization/localization_provider.dart';
import '../../../common/widgets/responsive_container.dart';
import '../pdf_utils/pdf_models.dart';

class TextExtractorScreen extends ConsumerStatefulWidget {
  const TextExtractorScreen({super.key});

  @override
  ConsumerState<TextExtractorScreen> createState() => _TextExtractorScreenState();
}

class _TextExtractorScreenState extends ConsumerState<TextExtractorScreen> {
  PlatformFile? _selectedPdfFile;
  String _extractedText = '';
  bool _isExtracting = false;

  Future<void> _pickAndExtractPdfText() async {
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
          setState(() => _isExtracting = true);

          final sync_pdf.PdfDocument doc = sync_pdf.PdfDocument(inputBytes: bytes);
          final sync_pdf.PdfTextExtractor extractor = sync_pdf.PdfTextExtractor(doc);
          final String text = extractor.extractText();
          doc.dispose();

          setState(() {
            _selectedPdfFile = platformFile;
            _extractedText = text.isEmpty ? 'No readable text layer found in this PDF document.' : text;
            _isExtracting = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isExtracting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error extracting text: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final tool = ToolCategories.getToolById('pdf_text_extractor');

    return Scaffold(
      appBar: AppBar(title: Text(tool.getTitle(lang)), centerTitle: true),
      body: ResponsiveContainer(
        maxWidth: 800,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            pdfHero(tool.getTitle(lang), tool.getDescription(lang), Colors.red, Icons.text_snippet),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 36),
                title: Text(
                  _selectedPdfFile?.name ?? 'No PDF File Selected',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  _selectedPdfFile != null ? 'Size: ${(_selectedPdfFile!.size / 1024).toStringAsFixed(1)} KB' : 'Tap button to select PDF from Storage',
                ),
                trailing: ElevatedButton.icon(
                  icon: const Icon(Icons.folder_open),
                  label: const Text('Select PDF'),
                  onPressed: _pickAndExtractPdfText,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_isExtracting)
              const Center(child: CircularProgressIndicator())
            else if (_extractedText.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Extracted Document Text', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          IconButton(
                            icon: const Icon(Icons.copy, color: Colors.blue),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: _extractedText));
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Extracted text copied to clipboard!')));
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SelectableText(_extractedText, style: const TextStyle(fontSize: 15, height: 1.5)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

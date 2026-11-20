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

class PdfMergerScreen extends ConsumerStatefulWidget {
  const PdfMergerScreen({super.key});

  @override
  ConsumerState<PdfMergerScreen> createState() => _PdfMergerScreenState();
}

class _PdfMergerScreenState extends ConsumerState<PdfMergerScreen> {
  final List<PlatformFile> _selectedPdfFiles = [];

  bool _isMerging = false;
  Uint8List? _mergedPdfBytes;
  int _mergedFilesCount = 0;

  Future<void> _pickRealPdfFiles() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedPdfFiles.addAll(result.files);
          _mergedPdfBytes = null; // Reset previous merge preview
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF File Picker Error: $e')),
        );
      }
    }
  }

  Future<void> _mergePdfDocuments() async {
    if (_selectedPdfFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least 1 PDF file to merge.')),
      );
      return;
    }

    setState(() {
      _isMerging = true;
    });

    try {
      final sync_pdf.PdfDocument outputDocument = sync_pdf.PdfDocument();

      for (int i = 0; i < _selectedPdfFiles.length; i++) {
        final platformFile = _selectedPdfFiles[i];
        Uint8List? bytes = platformFile.bytes;

        if (bytes == null && platformFile.path != null && !kIsWeb) {
          bytes = await File(platformFile.path!).readAsBytes();
        }

        if (bytes != null && bytes.isNotEmpty) {
          final sync_pdf.PdfDocument inputDocument = sync_pdf.PdfDocument(inputBytes: bytes);
          for (int pageIdx = 0; pageIdx < inputDocument.pages.count; pageIdx++) {
            final sync_pdf.PdfTemplate template = inputDocument.pages[pageIdx].createTemplate();
            final sync_pdf.PdfPage newPage = outputDocument.pages.add();
            newPage.graphics.drawPdfTemplate(template, const Offset(0, 0));
          }
          inputDocument.dispose();
        }
      }

      final List<int> savedList = await outputDocument.save();
      outputDocument.dispose();

      final Uint8List mergedBytes = Uint8List.fromList(savedList);

      if (mounted) {
        setState(() {
          _mergedPdfBytes = mergedBytes;
          _mergedFilesCount = _selectedPdfFiles.length;
          _isMerging = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All Original PDF Pages & Graphics Merged Successfully! Ready for Download.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isMerging = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error merging PDF files: $e')),
        );
      }
    }
  }

  Future<void> _downloadMergedPdf() async {
    if (_mergedPdfBytes == null) return;
    await FileSaveService.savePdfToDevice(context, _mergedPdfBytes!, 'Merged_PDF');
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final tool = ToolCategories.getToolById('pdf_merger');

    return Scaffold(
      appBar: AppBar(title: Text(tool.getTitle(lang)), centerTitle: true),
      body: ResponsiveContainer(
        maxWidth: 800,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            pdfHero(
              tool.getTitle(lang),
              tool.getDescription(lang),
              Colors.red,
              Icons.merge_type,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Selected PDF Files (${_selectedPdfFiles.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Add PDF File'),
                  onPressed: _pickRealPdfFiles,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_selectedPdfFiles.isEmpty)
              Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                ),
                child: InkWell(
                  onTap: _pickRealPdfFiles,
                  borderRadius: BorderRadius.circular(16),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.picture_as_pdf, size: 48, color: Colors.red),
                      SizedBox(height: 8),
                      Text('Tap to select PDF files from Storage', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              )
            else
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _selectedPdfFiles.length,
                onReorderItem: (oldIdx, newIdx) {
                  setState(() {
                    final item = _selectedPdfFiles.removeAt(oldIdx);
                    _selectedPdfFiles.insert(newIdx, item);
                    _mergedPdfBytes = null;
                  });
                },
                itemBuilder: (context, index) {
                  final file = _selectedPdfFiles[index];
                  final fileSizeKb = (file.size / 1024).toStringAsFixed(1);
                  return Card(
                    key: ValueKey('${file.name}_$index'),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.redAccent,
                        child: Icon(Icons.picture_as_pdf, color: Colors.white, size: 20),
                      ),
                      title: Text(file.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Size: $fileSizeKb KB • Sequence #${index + 1}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _selectedPdfFiles.removeAt(index);
                                _mergedPdfBytes = null;
                              });
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

            // Merge Action Button
            if (_isMerging)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text('Merging Actual PDF Document Pages...', style: TextStyle(fontWeight: FontWeight.bold)),
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
                icon: const Icon(Icons.merge_type),
                label: const Text('Merge PDF Documents', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                onPressed: _mergePdfDocuments,
              ),

            // Download Preview Section
            if (_mergedPdfBytes != null) ...[
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
                        'PDF Pages Merged Successfully!',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$_mergedFilesCount Files Combined • ${(_mergedPdfBytes!.lengthInBytes / (1024 * 1024)).toStringAsFixed(2)} MB',
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
                          'Download Merged PDF to Device (ডাউনলোড করুন)',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        onPressed: _downloadMergedPdf,
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

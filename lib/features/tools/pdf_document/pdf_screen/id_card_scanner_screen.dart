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

class IdCardScannerScreen extends ConsumerStatefulWidget {
  const IdCardScannerScreen({super.key});

  @override
  ConsumerState<IdCardScannerScreen> createState() => _IdCardScannerScreenState();
}

class _IdCardScannerScreenState extends ConsumerState<IdCardScannerScreen> {
  XFile? _frontImage;
  XFile? _backImage;

  bool _isGenerating = false;
  Uint8List? _generatedPdfBytes;

  Future<void> _pickCardSide(bool isFront, ImageSource source) async {
    final picker = ImagePicker();
    try {
      final photo = await picker.pickImage(source: source);
      if (photo != null) {
        setState(() {
          if (isFront) {
            _frontImage = photo;
          } else {
            _backImage = photo;
          }
          _generatedPdfBytes = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting card image: $e')),
        );
      }
    }
  }

  Future<void> _generateCombinedIdCardPdf() async {
    if (_frontImage == null && _backImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please scan or pick at least one side of the ID card.')),
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final pdfDoc = pw.Document();

      Uint8List? frontBytes = _frontImage != null ? await _frontImage!.readAsBytes() : null;
      Uint8List? backBytes = _backImage != null ? await _backImage!.readAsBytes() : null;

      pdfDoc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context ctx) {
            return pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text('NID / Smart ID Card Document', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 24),

                  if (frontBytes != null) ...[
                    pw.Text('Front Side', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 8),
                    pw.Container(
                      height: 180,
                      decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey)),
                      child: pw.Image(pw.MemoryImage(frontBytes), fit: pw.BoxFit.contain),
                    ),
                    pw.SizedBox(height: 24),
                  ],

                  if (backBytes != null) ...[
                    pw.Text('Back Side', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 8),
                    pw.Container(
                      height: 180,
                      decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey)),
                      child: pw.Image(pw.MemoryImage(backBytes), fit: pw.BoxFit.contain),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      );

      final Uint8List bytes = await pdfDoc.save();

      if (mounted) {
        setState(() {
          _generatedPdfBytes = bytes;
          _isGenerating = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Combined ID Card PDF Generated! Ready for Download.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGenerating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating ID card PDF: $e')),
        );
      }
    }
  }

  Future<void> _downloadPdf() async {
    if (_generatedPdfBytes == null) return;
    await FileSaveService.savePdfToDevice(context, _generatedPdfBytes!, 'NID_Card_Document');
  }

  @override
  Widget build(BuildContext context) {
    final langNotifier = ref.watch(languageProvider.notifier);
    final lang = ref.watch(languageProvider);
    final tool = ToolCategories.getToolById('id_card_scanner');

    return Scaffold(
      appBar: AppBar(title: Text(tool.getTitle(lang)), centerTitle: true),
      body: ResponsiveContainer(
        maxWidth: 800,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            pdfHero(tool.getTitle(lang), tool.getDescription(lang), Colors.red, Icons.badge),
            const SizedBox(height: 16),

            // Front Side Scanner Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(langNotifier.translate('scan_front'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Row(
                          children: [
                            IconButton(icon: const Icon(Icons.camera_alt, color: Colors.green), onPressed: () => _pickCardSide(true, ImageSource.camera)),
                            IconButton(icon: const Icon(Icons.photo_library, color: Colors.blue), onPressed: () => _pickCardSide(true, ImageSource.gallery)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 140,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                      ),
                      child: _frontImage == null
                          ? const Center(child: Text('Tap icons above to capture Front Side', style: TextStyle(color: Colors.grey)))
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: kIsWeb
                                  ? Image.network(_frontImage!.path, fit: BoxFit.cover)
                                  : Image.file(File(_frontImage!.path), fit: BoxFit.cover),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Back Side Scanner Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(langNotifier.translate('scan_back'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Row(
                          children: [
                            IconButton(icon: const Icon(Icons.camera_alt, color: Colors.green), onPressed: () => _pickCardSide(false, ImageSource.camera)),
                            IconButton(icon: const Icon(Icons.photo_library, color: Colors.blue), onPressed: () => _pickCardSide(false, ImageSource.gallery)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 140,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                      ),
                      child: _backImage == null
                          ? const Center(child: Text('Tap icons above to capture Back Side', style: TextStyle(color: Colors.grey)))
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: kIsWeb
                                  ? Image.network(_backImage!.path, fit: BoxFit.cover)
                                  : Image.file(File(_backImage!.path), fit: BoxFit.cover),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Generate Action Button
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
                label: Text(langNotifier.translate('combine_id_card'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                onPressed: _generateCombinedIdCardPdf,
              ),

            // Download Preview Section
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
                        'ID Card PDF Ready!',
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
                          'Download ID Card PDF (ডাউনলোড করুন)',
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

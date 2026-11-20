import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../core/constants/tool_categories.dart';
import '../../../../core/localization/localization_provider.dart';
import '../../../../core/services/file_save_service.dart';
import '../../../common/widgets/responsive_container.dart';
import '../pdf_utils/pdf_models.dart';

class QrToPdfScreen extends ConsumerStatefulWidget {
  const QrToPdfScreen({super.key});

  @override
  ConsumerState<QrToPdfScreen> createState() => _QrToPdfScreenState();
}

class _QrToPdfScreenState extends ConsumerState<QrToPdfScreen> {
  final TextEditingController _contentCtrl = TextEditingController(text: 'https://onetools.studio/invite');
  final TextEditingController _titleCtrl = TextEditingController(text: 'Official Product QR Code');

  bool _isGenerating = false;
  Uint8List? _generatedPdfBytes;

  Future<void> _generateQrPdf() async {
    if (_contentCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter QR text content.')),
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final pdfDoc = pw.Document();

      pdfDoc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context ctx) {
            return pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(_titleCtrl.text, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 24),
                  pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(),
                    data: _contentCtrl.text,
                    width: 200,
                    height: 200,
                  ),
                  pw.SizedBox(height: 16),
                  pw.Text('Scannable Code: ${_contentCtrl.text}', style: const pw.TextStyle(color: PdfColors.grey)),
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
            content: Text('QR Code PDF Document Ready for Download!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGenerating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating QR PDF: $e')),
        );
      }
    }
  }

  Future<void> _downloadPdf() async {
    if (_generatedPdfBytes == null) return;
    await FileSaveService.savePdfToDevice(context, _generatedPdfBytes!, 'QR_Code_PDF');
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final tool = ToolCategories.getToolById('qr_to_pdf');

    return Scaffold(
      appBar: AppBar(title: Text(tool.getTitle(lang)), centerTitle: true),
      body: ResponsiveContainer(
        maxWidth: 800,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            pdfHero(tool.getTitle(lang), tool.getDescription(lang), Colors.red, Icons.qr_code_2),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _titleCtrl,
                      decoration: const InputDecoration(labelText: 'PDF Header Title', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _contentCtrl,
                      decoration: const InputDecoration(labelText: 'QR Code URL / Content Data', border: OutlineInputBorder()),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

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
                label: const Text('Generate QR Code PDF Document', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                onPressed: _generateQrPdf,
              ),

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
                        'QR Code PDF Ready!',
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
                          'Download QR PDF to Device (ডাউনলোড করুন)',
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

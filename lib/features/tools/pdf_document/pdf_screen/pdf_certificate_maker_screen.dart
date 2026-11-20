import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/tool_categories.dart';
import '../../../../core/localization/localization_provider.dart';
import '../../../../core/services/file_save_service.dart';
import '../../../common/widgets/responsive_container.dart';

import '../pdf_services/pdf_generator_service.dart';
import '../pdf_utils/pdf_models.dart';

class PdfCertificateMakerScreen extends ConsumerStatefulWidget {
  const PdfCertificateMakerScreen({super.key});

  @override
  ConsumerState<PdfCertificateMakerScreen> createState() => _PdfCertificateMakerScreenState();
}

class _PdfCertificateMakerScreenState extends ConsumerState<PdfCertificateMakerScreen> {
  final TextEditingController _recipientCtrl = TextEditingController(text: 'Sultana Parvin');
  final TextEditingController _courseCtrl = TextEditingController(text: 'Full-Stack Web & App Development');
  final TextEditingController _instructorCtrl = TextEditingController(text: 'OneTools Studio Academy');

  bool _isGenerating = false;
  Uint8List? _generatedCertPdf;

  Future<void> _generateCertificate() async {
    setState(() => _isGenerating = true);

    try {
      final Uint8List pdfBytes = await PdfGeneratorService.generateCertificatePdf(
        recipientName: _recipientCtrl.text,
        courseTitle: _courseCtrl.text,
        issueDate: DateFormat('dd MMMM yyyy').format(DateTime.now()),
        instructorName: _instructorCtrl.text,
      );

      if (mounted) {
        setState(() {
          _generatedCertPdf = pdfBytes;
          _isGenerating = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Certificate PDF Generated! Ready for Download.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGenerating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating Certificate PDF: $e')),
        );
      }
    }
  }

  Future<void> _downloadCertPdf() async {
    if (_generatedCertPdf == null) return;
    await FileSaveService.savePdfToDevice(context, _generatedCertPdf!, 'Certificate_Achievement');
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final tool = ToolCategories.getToolById('pdf_splitter');

    return Scaffold(
      appBar: AppBar(title: const Text('Certificate PDF Maker'), centerTitle: true),
      body: ResponsiveContainer(
        maxWidth: 800,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            pdfHero('Certificate PDF Maker', 'Design and generate official training achievement certificates', Colors.red, Icons.card_membership),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _recipientCtrl,
                      decoration: const InputDecoration(labelText: 'Recipient Full Name', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _courseCtrl,
                      decoration: const InputDecoration(labelText: 'Course / Event Title', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _instructorCtrl,
                      decoration: const InputDecoration(labelText: 'Issuing Organization / Instructor', border: OutlineInputBorder()),
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
                icon: const Icon(Icons.card_membership),
                label: const Text('Generate Certificate PDF', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                onPressed: _generateCertificate,
              ),

            if (_generatedCertPdf != null) ...[
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
                        'Certificate PDF Ready!',
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
                          'Download Certificate PDF (ডাউনলোড করুন)',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        onPressed: _downloadCertPdf,
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

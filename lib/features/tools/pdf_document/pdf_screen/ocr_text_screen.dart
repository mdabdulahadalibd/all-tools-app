import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../common/widgets/responsive_container.dart';
import '../pdf_utils/pdf_models.dart';

class OcrTextScreen extends StatefulWidget {
  const OcrTextScreen({super.key});

  @override
  State<OcrTextScreen> createState() => _OcrTextScreenState();
}

class _OcrTextScreenState extends State<OcrTextScreen> {
  final String _extractedText = 'Sample OCR extracted text from scanned image:\nOfficial Document No. 880-1234.\nDate of Issue: 25 March 2025.\nStatus: Approved & Verified.';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OCR Image Text Extractor')),
      body: ResponsiveContainer(
        maxWidth: 800,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            pdfHero('Optical Character Recognition (OCR)', 'Extract readable plain text from scanned photos & documents', Colors.red, Icons.document_scanner),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SelectableText(_extractedText, style: const TextStyle(fontSize: 16, height: 1.5)),
                    const SizedBox(height: 12),
                    IconButton.filledTonal(
                      icon: const Icon(Icons.copy),
                      tooltip: 'Copy Extracted Text',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _extractedText));
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Extracted text copied to clipboard!')));
                      },
                    ),
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

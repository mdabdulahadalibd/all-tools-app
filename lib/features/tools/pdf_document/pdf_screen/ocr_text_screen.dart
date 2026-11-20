import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/tool_categories.dart';
import '../../../../core/localization/localization_provider.dart';
import '../../../common/widgets/responsive_container.dart';
import '../pdf_utils/pdf_models.dart';

class OcrTextScreen extends ConsumerStatefulWidget {
  const OcrTextScreen({super.key});

  @override
  ConsumerState<OcrTextScreen> createState() => _OcrTextScreenState();
}

class _OcrTextScreenState extends ConsumerState<OcrTextScreen> {
  final String _extractedText = 'Sample OCR extracted text from scanned document:\nInvoice No: #INV-2025-8821\nAmount Due: ৳ 14,500\nIssue Date: 26 March 2025\nStatus: Paid & Verified.';

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final tool = ToolCategories.getToolById('ocr_text');

    return Scaffold(
      appBar: AppBar(title: Text(tool.getTitle(lang)), centerTitle: true),
      body: ResponsiveContainer(
        maxWidth: 800,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            pdfHero(tool.getTitle(lang), tool.getDescription(lang), Colors.red, Icons.document_scanner),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(_extractedText, style: const TextStyle(fontSize: 16, height: 1.5)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.copy),
                          label: const Text('Copy Text'),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _extractedText));
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Extracted text copied to clipboard!')));
                          },
                        ),
                      ],
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

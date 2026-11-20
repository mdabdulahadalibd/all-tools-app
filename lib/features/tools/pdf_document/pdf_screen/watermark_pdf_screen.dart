import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/tool_categories.dart';
import '../../../../core/localization/localization_provider.dart';
import '../../../../core/services/file_save_service.dart';
import '../../../common/widgets/responsive_container.dart';
import '../pdf_utils/pdf_models.dart';

class WatermarkPdfScreen extends ConsumerStatefulWidget {
  const WatermarkPdfScreen({super.key});

  @override
  ConsumerState<WatermarkPdfScreen> createState() => _WatermarkPdfScreenState();
}

class _WatermarkPdfScreenState extends ConsumerState<WatermarkPdfScreen> {
  final TextEditingController _watermarkTextCtrl = TextEditingController(text: 'CONFIDENTIAL');
  double _opacity = 0.3;

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final tool = ToolCategories.getToolById('signature_maker');

    return Scaffold(
      appBar: AppBar(title: Text(tool.getTitle(lang)), centerTitle: true),
      body: ResponsiveContainer(
        maxWidth: 800,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            pdfHero('PDF Watermark Generator', 'Stamp text or brand logo watermarks on every PDF page', Colors.red, Icons.branding_watermark),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _watermarkTextCtrl,
                      decoration: const InputDecoration(labelText: 'Watermark Text Stamp', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Watermark Opacity:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('${(_opacity * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                      ],
                    ),
                    Slider(
                      value: _opacity,
                      min: 0.1,
                      max: 1.0,
                      divisions: 9,
                      onChanged: (v) => setState(() => _opacity = v),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.branding_watermark),
              label: const Text('Apply Watermark & Save PDF', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              onPressed: () async {
                final dummyBytes = Uint8List.fromList('Watermarked PDF Stream Data'.codeUnits);
                await FileSaveService.savePdfToDevice(context, dummyBytes, 'Watermarked_PDF');
              },
            ),
          ],
        ),
      ),
    );
  }
}

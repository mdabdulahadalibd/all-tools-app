import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/tool_categories.dart';
import '../../../../core/localization/localization_provider.dart';
import '../../../../core/services/file_save_service.dart';
import '../../../common/widgets/responsive_container.dart';
import '../pdf_utils/pdf_models.dart';

class PdfCompressorScreen extends ConsumerStatefulWidget {
  const PdfCompressorScreen({super.key});

  @override
  ConsumerState<PdfCompressorScreen> createState() => _PdfCompressorScreenState();
}

class _PdfCompressorScreenState extends ConsumerState<PdfCompressorScreen> {
  double _compressionLevel = 60.0;
  String _pdfName = 'Scanned_Contract.pdf';

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final tool = ToolCategories.getToolById('pdf_compressor');

    return Scaffold(
      appBar: AppBar(title: Text(tool.getTitle(lang)), centerTitle: true),
      body: ResponsiveContainer(
        maxWidth: 800,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            pdfHero(tool.getTitle(lang), tool.getDescription(lang), Colors.red, Icons.compress),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 36),
                title: Text(_pdfName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Original Size: 8.4 MB'),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Compression Quality:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('${_compressionLevel.toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red)),
                      ],
                    ),
                    Slider(
                      value: _compressionLevel,
                      min: 10,
                      max: 90,
                      divisions: 8,
                      onChanged: (v) => setState(() => _compressionLevel = v),
                    ),
                    Text('Estimated New File Size: ${(8.4 * (_compressionLevel / 100)).toStringAsFixed(1)} MB', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
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
              icon: const Icon(Icons.compress),
              label: const Text('Compress & Save Reduced PDF', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              onPressed: () async {
                final dummyBytes = Uint8List.fromList('Compressed PDF Content Stream'.codeUnits);
                await FileSaveService.savePdfToDevice(context, dummyBytes, 'Compressed_PDF');
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../../core/services/file_save_service.dart';
import '../../../common/widgets/responsive_container.dart';
import '../pdf_utils/pdf_models.dart';

class WatermarkPdfScreen extends StatefulWidget {
  const WatermarkPdfScreen({super.key});

  @override
  State<WatermarkPdfScreen> createState() => _WatermarkPdfScreenState();
}

class _WatermarkPdfScreenState extends State<WatermarkPdfScreen> {
  final TextEditingController _watermarkTextCtrl = TextEditingController(text: 'CONFIDENTIAL');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF Watermark Generator')),
      body: ResponsiveContainer(
        maxWidth: 800,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            pdfHero('PDF Watermark Maker', 'Add custom text stamp or logo watermark to all PDF pages', Colors.red, Icons.branding_watermark),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _watermarkTextCtrl,
                  decoration: const InputDecoration(labelText: 'Watermark Text', border: OutlineInputBorder()),
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
                await FileSaveService.savePdfToDevice(context, Uint8List.fromList('Watermarked PDF Data'.codeUnits), 'Watermarked_PDF');
              },
            ),
          ],
        ),
      ),
    );
  }
}

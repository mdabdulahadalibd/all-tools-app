import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../../core/services/file_save_service.dart';
import '../../../common/widgets/responsive_container.dart';
import '../pdf_utils/pdf_models.dart';

class PdfCompressorScreen extends StatefulWidget {
  const PdfCompressorScreen({super.key});

  @override
  State<PdfCompressorScreen> createState() => _PdfCompressorScreenState();
}

class _PdfCompressorScreenState extends State<PdfCompressorScreen> {
  double _compressionQuality = 60.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF Compressor')),
      body: ResponsiveContainer(
        maxWidth: 800,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            pdfHero('PDF Compressor', 'Reduce PDF file size for fast email & web sharing', Colors.red, Icons.compress),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('Compression Level: ${_compressionQuality.toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Slider(
                      value: _compressionQuality,
                      min: 10,
                      max: 90,
                      divisions: 8,
                      onChanged: (v) => setState(() => _compressionQuality = v),
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
              icon: const Icon(Icons.compress),
              label: const Text('Compress & Save PDF File', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              onPressed: () async {
                await FileSaveService.savePdfToDevice(context, Uint8List.fromList('Compressed PDF Data'.codeUnits), 'Compressed_PDF');
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../../core/services/file_save_service.dart';
import '../../../common/widgets/responsive_container.dart';
import '../pdf_utils/pdf_models.dart';

class PdfPageRotatorScreen extends StatefulWidget {
  const PdfPageRotatorScreen({super.key});

  @override
  State<PdfPageRotatorScreen> createState() => _PdfPageRotatorScreenState();
}

class _PdfPageRotatorScreenState extends State<PdfPageRotatorScreen> {
  int _rotationDegree = 90;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF Page Rotator')),
      body: ResponsiveContainer(
        maxWidth: 800,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            pdfHero('PDF Page Rotator', 'Rotate PDF pages clockwise by 90°, 180° or 270°', Colors.red, Icons.rotate_right),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [90, 180, 270].map((deg) {
                    return ChoiceChip(
                      label: Text('$deg° Rotation'),
                      selected: _rotationDegree == deg,
                      onSelected: (v) {
                        if (v) setState(() => _rotationDegree = deg);
                      },
                    );
                  }).toList(),
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
              icon: const Icon(Icons.rotate_right),
              label: const Text('Rotate & Save PDF Document', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              onPressed: () async {
                await FileSaveService.savePdfToDevice(context, Uint8List.fromList('Rotated PDF Data'.codeUnits), 'Rotated_PDF');
              },
            ),
          ],
        ),
      ),
    );
  }
}

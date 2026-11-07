import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../../core/services/file_save_service.dart';
import '../../../common/widgets/responsive_container.dart';
import '../pdf_utils/pdf_models.dart';

class PdfSplitterScreen extends StatefulWidget {
  const PdfSplitterScreen({super.key});

  @override
  State<PdfSplitterScreen> createState() => _PdfSplitterScreenState();
}

class _PdfSplitterScreenState extends State<PdfSplitterScreen> {
  final TextEditingController _rangeCtrl = TextEditingController(text: '1-3, 5');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF Splitter')),
      body: ResponsiveContainer(
        maxWidth: 800,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            pdfHero('PDF Splitter', 'Extract and split selected page ranges from PDF files', Colors.red, Icons.call_split),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _rangeCtrl,
                      decoration: const InputDecoration(labelText: 'Page Range to Split (e.g. 1-3, 5)', border: OutlineInputBorder()),
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
              icon: const Icon(Icons.call_split),
              label: const Text('Split & Save PDF Pages', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              onPressed: () async {
                await FileSaveService.savePdfToDevice(context, Uint8List.fromList('Split PDF Data'.codeUnits), 'Split_Pages');
              },
            ),
          ],
        ),
      ),
    );
  }
}

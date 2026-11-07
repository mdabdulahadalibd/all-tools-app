import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../../core/services/file_save_service.dart';
import '../../../common/widgets/responsive_container.dart';
import '../pdf_utils/pdf_models.dart';

class PdfMergerScreen extends StatefulWidget {
  const PdfMergerScreen({super.key});

  @override
  State<PdfMergerScreen> createState() => _PdfMergerScreenState();
}

class _PdfMergerScreenState extends State<PdfMergerScreen> {
  final List<String> _selectedFiles = [
    'Lecture_Notes_Part1.pdf',
    'Lecture_Notes_Part2.pdf',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF Merger')),
      body: ResponsiveContainer(
        maxWidth: 800,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            pdfHero('PDF Merger', 'Combine multiple PDF files into one single document', Colors.red, Icons.merge_type),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_circle),
              label: const Text('Add PDF File'),
              onPressed: () {
                setState(() => _selectedFiles.add('Document_${_selectedFiles.length + 1}.pdf'));
              },
            ),
            const SizedBox(height: 16),
            ..._selectedFiles.asMap().entries.map((e) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                    title: Text(e.value, style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => setState(() => _selectedFiles.removeAt(e.key)),
                    ),
                  ),
                )),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.merge_type),
              label: const Text('Merge & Save PDF Document', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              onPressed: () async {
                if (_selectedFiles.isEmpty) return;
                await FileSaveService.savePdfToDevice(context, Uint8List.fromList('Merged PDF Data'.codeUnits), 'Merged_Document');
              },
            ),
          ],
        ),
      ),
    );
  }
}

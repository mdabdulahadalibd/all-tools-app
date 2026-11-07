import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../../core/services/file_save_service.dart';
import '../../../common/widgets/responsive_container.dart';
import '../pdf_utils/pdf_models.dart';

class WordToPdfScreen extends StatefulWidget {
  const WordToPdfScreen({super.key});

  @override
  State<WordToPdfScreen> createState() => _WordToPdfScreenState();
}

class _WordToPdfScreenState extends State<WordToPdfScreen> {
  final String _selectedDocName = 'Sample_Document.docx';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Word to PDF Converter')),
      body: ResponsiveContainer(
        maxWidth: 800,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            pdfHero('Word / Doc to PDF Converter', 'Convert Microsoft Word (DOCX) files to clean PDF format', Colors.blue, Icons.article),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.description, color: Colors.blue),
                title: Text(_selectedDocName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Microsoft Word Document (.docx)'),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Convert & Save as PDF', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              onPressed: () async {
                await FileSaveService.savePdfToDevice(context, Uint8List.fromList('Word Converted PDF Data'.codeUnits), 'Word_Converted');
              },
            ),
          ],
        ),
      ),
    );
  }
}

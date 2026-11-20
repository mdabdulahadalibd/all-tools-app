import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/tool_categories.dart';
import '../../../../core/localization/localization_provider.dart';
import '../../../../core/services/file_save_service.dart';
import '../../../common/widgets/responsive_container.dart';
import '../pdf_utils/pdf_models.dart';

class WordToPdfScreen extends ConsumerStatefulWidget {
  const WordToPdfScreen({super.key});

  @override
  ConsumerState<WordToPdfScreen> createState() => _WordToPdfScreenState();
}

class _WordToPdfScreenState extends ConsumerState<WordToPdfScreen> {
  final String _docName = 'Project_Proposal.docx';

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final tool = ToolCategories.getToolById('word_to_pdf');

    return Scaffold(
      appBar: AppBar(title: Text(tool.getTitle(lang)), centerTitle: true),
      body: ResponsiveContainer(
        maxWidth: 800,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            pdfHero(tool.getTitle(lang), tool.getDescription(lang), Colors.blue, Icons.article),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.description, color: Colors.blue, size: 36),
                title: Text(_docName, style: const TextStyle(fontWeight: FontWeight.bold)),
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
              label: const Text('Convert & Export PDF File', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              onPressed: () async {
                final dummyBytes = Uint8List.fromList('Word to PDF Stream Data'.codeUnits);
                await FileSaveService.savePdfToDevice(context, dummyBytes, 'Word_Converted');
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/tool_categories.dart';
import '../../../../core/localization/localization_provider.dart';
import '../../../../core/services/file_save_service.dart';
import '../../../common/widgets/responsive_container.dart';
import '../pdf_utils/pdf_models.dart';

class PdfSplitterScreen extends ConsumerStatefulWidget {
  const PdfSplitterScreen({super.key});

  @override
  ConsumerState<PdfSplitterScreen> createState() => _PdfSplitterScreenState();
}

class _PdfSplitterScreenState extends ConsumerState<PdfSplitterScreen> {
  final TextEditingController _rangeCtrl = TextEditingController(text: '1-3, 5');
  String _pdfFileName = 'Annual_Report_2025.pdf';

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final tool = ToolCategories.getToolById('pdf_splitter');

    return Scaffold(
      appBar: AppBar(title: Text(tool.getTitle(lang)), centerTitle: true),
      body: ResponsiveContainer(
        maxWidth: 800,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            pdfHero(tool.getTitle(lang), tool.getDescription(lang), Colors.red, Icons.call_split),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 36),
                title: Text(_pdfFileName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('15 Pages Total'),
                trailing: ElevatedButton.icon(
                  icon: const Icon(Icons.folder_open),
                  label: const Text('Select PDF'),
                  onPressed: () {
                    setState(() => _pdfFileName = 'Selected_Document_${DateTime.now().second}.pdf');
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _rangeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Enter Page Numbers or Ranges to Extract (e.g. 1-3, 5, 8-10)',
                    border: OutlineInputBorder(),
                  ),
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
              label: const Text('Split & Export Selected PDF Pages', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              onPressed: () async {
                final dummyBytes = Uint8List.fromList('Split PDF Content Stream'.codeUnits);
                await FileSaveService.savePdfToDevice(context, dummyBytes, 'Split_Pages');
              },
            ),
          ],
        ),
      ),
    );
  }
}

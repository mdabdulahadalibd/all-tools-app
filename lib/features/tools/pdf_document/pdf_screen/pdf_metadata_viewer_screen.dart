import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/tool_categories.dart';
import '../../../../core/localization/localization_provider.dart';
import '../../../common/widgets/responsive_container.dart';
import '../pdf_utils/pdf_models.dart';

class PdfMetadataViewerScreen extends ConsumerWidget {
  const PdfMetadataViewerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    final tool = ToolCategories.getToolById('pdf_metadata_viewer');

    return Scaffold(
      appBar: AppBar(title: Text(tool.getTitle(lang)), centerTitle: true),
      body: ResponsiveContainer(
        maxWidth: 800,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            pdfHero(tool.getTitle(lang), tool.getDescription(lang), Colors.red, Icons.info),
            const SizedBox(height: 16),
            const Card(
              child: Column(
                children: [
                  ListTile(title: Text('Document Title'), subtitle: Text('Official_Report_2025.pdf', style: TextStyle(fontWeight: FontWeight.bold))),
                  Divider(height: 1),
                  ListTile(title: Text('Total Page Count'), subtitle: Text('14 Pages', style: TextStyle(fontWeight: FontWeight.bold))),
                  Divider(height: 1),
                  ListTile(title: Text('PDF Specification Version'), subtitle: Text('PDF v1.7 (Acrobat 8.x)', style: TextStyle(fontWeight: FontWeight.bold))),
                  Divider(height: 1),
                  ListTile(title: Text('Creation Timestamp'), subtitle: Text('2025-03-26 10:30:00 UTC', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

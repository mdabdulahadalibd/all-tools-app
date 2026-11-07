export 'pdf_provider/pdf_tools_provider.dart';
export 'pdf_screen/id_card_scanner_screen.dart';
export 'pdf_screen/image_to_pdf_screen.dart';
export 'pdf_screen/ocr_text_screen.dart';
export 'pdf_screen/pdf_compress_watermark_screen.dart';
export 'pdf_screen/pdf_compressor_screen.dart';
export 'pdf_screen/pdf_lock_unlock_screen.dart';
export 'pdf_screen/pdf_merge_split_screen.dart';
export 'pdf_screen/pdf_merger_screen.dart';
export 'pdf_screen/pdf_metadata_screen.dart';
export 'pdf_screen/pdf_metadata_viewer_screen.dart';
export 'pdf_screen/pdf_page_rotator_screen.dart';
export 'pdf_screen/pdf_reader_screen.dart';
export 'pdf_screen/pdf_splitter_screen.dart';
export 'pdf_screen/signature_maker_screen.dart';
export 'pdf_screen/text_extractor_screen.dart';
export 'pdf_screen/watermark_pdf_screen.dart';
export 'pdf_screen/word_doc_converter_screen.dart';
export 'pdf_screen/word_to_pdf_screen.dart';
export 'pdf_utils/pdf_models.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/tool_categories.dart';
import '../../../core/localization/localization_provider.dart';
import '../../common/widgets/responsive_container.dart';
import '../../common/widgets/tool_card.dart';
import 'pdf_utils/pdf_models.dart';

class PdfToolsScreen extends ConsumerWidget {
  const PdfToolsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final langNotifier = ref.watch(languageProvider.notifier);
    final lang = ref.watch(languageProvider);
    final pdfCategory = ToolCategories.getCategoryById('pdf_document');
    final pdfTools = ToolCategories.getToolsForCategory('pdf_document');

    return Scaffold(
      appBar: AppBar(
        title: Text(pdfCategory.getName(lang)),
      ),
      body: ResponsiveContainer(
        maxWidth: 900,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            pdfHero(
              pdfCategory.getName(lang),
              pdfCategory.getDescription(lang),
              pdfCategory.color,
              pdfCategory.icon,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  langNotifier.translate('all_tools'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${pdfTools.length} Tools',
                  style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...pdfTools.map((tool) => ToolCard(tool: tool)),
          ],
        ),
      ),
    );
  }
}

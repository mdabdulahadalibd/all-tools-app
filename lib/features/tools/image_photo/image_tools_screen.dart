export 'image_provider/image_tools_provider.dart';
export 'image_screen/color_picker_screen.dart';
export 'image_screen/exif_metadata_base64_screen.dart';
export 'image_screen/format_converter_screen.dart';
export 'image_screen/image_compressor_screen.dart';
export 'image_screen/image_resizer_compressor_screen.dart';
export 'image_screen/image_resizer_screen.dart';
export 'image_screen/passport_nid_photo_screen.dart';
export 'image_screen/photo_filters_editor_screen.dart';
export 'image_screen/photo_filters_screen.dart';
export 'image_utils/image_models.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/tool_categories.dart';
import '../../../core/localization/localization_provider.dart';
import '../../common/widgets/responsive_container.dart';
import '../../common/widgets/tool_card.dart';
import 'image_utils/image_models.dart';

class ImageToolsScreen extends ConsumerWidget {
  const ImageToolsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final langNotifier = ref.watch(languageProvider.notifier);
    final lang = ref.watch(languageProvider);
    final imgCategory = ToolCategories.getCategoryById('image_photo');
    final imgTools = ToolCategories.getToolsForCategory('image_photo');

    return Scaffold(
      appBar: AppBar(
        title: Text(imgCategory.getName(lang)),
      ),
      body: ResponsiveContainer(
        maxWidth: 900,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            imgHero(
              imgCategory.getName(lang),
              imgCategory.getDescription(lang),
              imgCategory.color,
              imgCategory.icon,
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
                  '${imgTools.length} Tools',
                  style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...imgTools.map((tool) => ToolCard(tool: tool)),
          ],
        ),
      ),
    );
  }
}

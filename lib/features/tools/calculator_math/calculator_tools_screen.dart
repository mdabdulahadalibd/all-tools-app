export 'calculator_provider/calculator_tools_provider.dart';
export 'calculator_screen/basic_calculator_screen.dart';
export 'calculator_screen/scientific_calculator_screen.dart';
export 'calculator_utils/calculator_models.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/tool_categories.dart';
import '../../../core/localization/localization_provider.dart';
import '../../common/widgets/responsive_container.dart';
import '../../common/widgets/tool_card.dart';
import 'calculator_utils/calculator_models.dart';

class CalculatorToolsScreen extends ConsumerWidget {
  const CalculatorToolsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final langNotifier = ref.watch(languageProvider.notifier);
    final lang = ref.watch(languageProvider);
    final mathCategory = ToolCategories.getCategoryById('calculator_math');
    final mathTools = ToolCategories.getToolsForCategory('calculator_math');

    return Scaffold(
      appBar: AppBar(
        title: Text(mathCategory.getName(lang)),
        centerTitle: true,
      ),
      body: ResponsiveContainer(
        maxWidth: 900,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            mathHero(
              mathCategory.getName(lang),
              mathCategory.getDescription(lang),
              mathCategory.color,
              mathCategory.icon,
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
                  '${mathTools.length} Tools',
                  style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...mathTools.map((tool) => ToolCard(tool: tool)),
          ],
        ),
      ),
    );
  }
}

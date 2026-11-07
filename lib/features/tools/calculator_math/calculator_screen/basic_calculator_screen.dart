import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/tool_categories.dart';
import '../../../../core/localization/localization_provider.dart';
import '../../../common/widgets/responsive_container.dart';
import '../calculator_provider/calculator_tools_provider.dart';

class BasicCalculatorScreen extends ConsumerWidget {
  const BasicCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    final tool = ToolCategories.getToolById('basic_calc');
    final calcState = ref.watch(basicCalcProvider);
    final notifier = ref.read(basicCalcProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(tool.getTitle(lang)),
        centerTitle: true,
      ),
      body: ResponsiveContainer(
        maxWidth: 600,
        child: Column(
          children: [
            // Display Area
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: Text(
                        calcState.expression.isEmpty ? '0' : calcState.expression,
                        style: TextStyle(
                          fontSize: 32,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: Text(
                        calcState.result,
                        style: TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),

            // Keypad Grid
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    _buildRow(context, notifier, ['AC', '±', '%', '÷']),
                    _buildRow(context, notifier, ['7', '8', '9', '×']),
                    _buildRow(context, notifier, ['4', '5', '6', '-']),
                    _buildRow(context, notifier, ['1', '2', '3', '+']),
                    _buildRow(context, notifier, ['0', '.', '⌫', '=']),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, BasicCalcNotifier notifier, List<String> keys) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: keys.map((key) {
          bool isOp = ['÷', '×', '-', '+', '='].contains(key);
          bool isAction = ['AC', '±', '%', '⌫'].contains(key);

          Color bg = isOp
              ? Colors.orange
              : (isAction ? Colors.blueGrey.shade100 : Theme.of(context).colorScheme.surfaceContainerHigh);

          Color textCol = isOp ? Colors.white : (isAction ? Colors.black87 : Theme.of(context).colorScheme.onSurface);

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: bg,
                  foregroundColor: textCol,
                  elevation: isOp ? 3 : 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                onPressed: () => notifier.pressKey(key),
                child: Text(
                  key,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textCol),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

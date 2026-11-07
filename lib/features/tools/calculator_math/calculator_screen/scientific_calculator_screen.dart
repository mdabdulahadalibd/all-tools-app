import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/tool_categories.dart';
import '../../../../core/localization/localization_provider.dart';
import '../../../common/widgets/responsive_container.dart';
import '../calculator_provider/calculator_tools_provider.dart';

class ScientificCalculatorScreen extends ConsumerWidget {
  const ScientificCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    final tool = ToolCategories.getToolById('scientific_calc');
    final state = ref.watch(sciCalcProvider);
    final notifier = ref.read(sciCalcProvider.notifier);

    final liveEval = SciCalcNotifier.evaluate(state.expression, state.isDeg);

    final keyLayout = <List<String>>[
      if (state.isScientificMode) ...[
        [state.isDeg ? 'DEG' : 'RAD', 'sin', 'cos', 'tan'],
        ['log', 'ln', 'sqrt', '^'],
        ['π', 'e', '(', ')'],
      ],
      ['C', '⌫', '%', '÷'],
      ['7', '8', '9', '×'],
      ['4', '5', '6', '−'],
      ['1', '2', '3', '+'],
      ['( )', '0', '.', '='],
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(tool.getTitle(lang)),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: state.isScientificMode ? 'Standard Mode' : 'Scientific Mode',
            icon: Icon(
              state.isScientificMode ? Icons.calculate : Icons.functions,
              color: Colors.blue,
            ),
            onPressed: () => notifier.toggleMode(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ResponsiveContainer(
        maxWidth: 600,
        child: Column(
          children: [
            // Top Display Card
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.indigo.shade900, Colors.blue.shade900],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            state.isDeg ? 'DEG' : 'RAD',
                            style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            state.history,
                            style: const TextStyle(fontSize: 16, color: Colors.white60),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        state.expression.isEmpty ? '0' : state.expression,
                        style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    if (liveEval != null && liveEval != state.expression)
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          '= $liveEval',
                          style: const TextStyle(fontSize: 22, color: Colors.lightGreenAccent, fontWeight: FontWeight.w600),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Keypad Grid
            Expanded(
              flex: state.isScientificMode ? 8 : 6,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  children: keyLayout.map((row) {
                    return Expanded(
                      child: Row(
                        children: row.map((key) => _buildKeyButton(context, notifier, key)).toList(),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyButton(BuildContext context, SciCalcNotifier notifier, String key) {
    Color bg = Theme.of(context).colorScheme.surfaceContainerHigh;
    Color fg = Theme.of(context).colorScheme.onSurface;

    if (key == '=') {
      bg = Colors.blue;
      fg = Colors.white;
    } else if (key == 'C') {
      bg = Colors.red.shade100;
      fg = Colors.red.shade900;
    } else if (key == '⌫') {
      bg = Colors.orange.shade100;
      fg = Colors.orange.shade900;
    } else if ('÷×−+^'.contains(key) || key == '%') {
      bg = Colors.blue.shade100;
      fg = Colors.blue.shade900;
    } else if (const {'sin', 'cos', 'tan', 'log', 'ln', 'sqrt'}.contains(key) ||
        ['π', 'e', 'DEG', 'RAD', '(', ')'].contains(key)) {
      bg = Colors.purple.shade100;
      fg = Colors.purple.shade900;
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: bg,
            foregroundColor: fg,
            elevation: key == '=' ? 4 : 1,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () => notifier.pressKey(key),
          child: Text(
            key == 'sqrt' ? '√' : key,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

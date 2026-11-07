import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/tool_categories.dart';
import '../../../../core/localization/localization_provider.dart';
import '../../../common/widgets/responsive_container.dart';

class FactorialCalculatorScreen extends ConsumerStatefulWidget {
  const FactorialCalculatorScreen({super.key});

  @override
  ConsumerState<FactorialCalculatorScreen> createState() => _FactorialCalculatorScreenState();
}

class _FactorialCalculatorScreenState extends ConsumerState<FactorialCalculatorScreen> {
  final TextEditingController _numCtrl = TextEditingController(text: '7');

  String _factorialResult = '5040';

  void _calculate() {
    int n = int.tryParse(_numCtrl.text) ?? 0;
    if (n < 0 || n > 20) {
      setState(() => _factorialResult = 'Max n = 20 for integer precision');
      return;
    }

    BigInt fact = BigInt.one;
    for (int i = 2; i <= n; i++) {
      fact *= BigInt.from(i);
    }

    setState(() => _factorialResult = fact.toString());
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final tool = ToolCategories.getToolById('factorial_calc');

    return Scaffold(
      appBar: AppBar(title: Text(tool.getTitle(lang)), centerTitle: true),
      body: ResponsiveContainer(
        maxWidth: 700,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: Colors.indigo.shade900,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text('${_numCtrl.text}! Factorial Value', style: const TextStyle(color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 8),
                    SelectableText(_factorialResult, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.amberAccent)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _numCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Enter Integer Number (n)', border: OutlineInputBorder()),
                  onChanged: (_) => _calculate(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

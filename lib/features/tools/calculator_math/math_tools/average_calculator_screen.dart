import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/tool_categories.dart';
import '../../../../core/localization/localization_provider.dart';
import '../../../common/widgets/responsive_container.dart';

class AverageCalculatorScreen extends ConsumerStatefulWidget {
  const AverageCalculatorScreen({super.key});

  @override
  ConsumerState<AverageCalculatorScreen> createState() => _AverageCalculatorScreenState();
}

class _AverageCalculatorScreenState extends ConsumerState<AverageCalculatorScreen> {
  final TextEditingController _inputCtrl = TextEditingController(text: '10, 20, 30, 40, 50');
  double _average = 30.0;
  double _sum = 150.0;
  int _count = 5;

  void _calculate() {
    List<double> nums = _inputCtrl.text.split(RegExp(r'[, ]+')).map((s) => double.tryParse(s.trim())).whereType<double>().toList();
    if (nums.isEmpty) return;

    double sum = nums.reduce((a, b) => a + b);
    setState(() {
      _count = nums.length;
      _sum = sum;
      _average = sum / nums.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final tool = ToolCategories.getToolById('average_calc');

    return Scaffold(
      appBar: AppBar(title: Text(tool.getTitle(lang)), centerTitle: true),
      body: ResponsiveContainer(
        maxWidth: 700,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: Colors.blue.shade900,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text('Average of $_count Values', style: const TextStyle(color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(_average.toStringAsFixed(2), style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.amberAccent)),
                    const SizedBox(height: 4),
                    Text('Total Sum: ${_sum.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _inputCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Enter Numbers (separated by space or comma)', border: OutlineInputBorder()),
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

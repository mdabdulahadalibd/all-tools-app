import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/tool_categories.dart';
import '../../../../../core/localization/localization_provider.dart';
import '../../../../common/widgets/responsive_container.dart';

class StatisticsCalculatorScreen extends ConsumerStatefulWidget {
  const StatisticsCalculatorScreen({super.key});

  @override
  ConsumerState<StatisticsCalculatorScreen> createState() => _StatisticsCalculatorScreenState();
}

class _StatisticsCalculatorScreenState extends ConsumerState<StatisticsCalculatorScreen> {
  final TextEditingController _dataCtrl = TextEditingController(text: '12, 15, 18, 20, 15, 25, 30');

  double _mean = 0.0;
  double _median = 0.0;
  String _mode = '';
  double _stdDev = 0.0;
  int _count = 0;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    List<double> numbers = _dataCtrl.text
        .split(RegExp(r'[, ]+'))
        .map((s) => double.tryParse(s.trim()))
        .whereType<double>()
        .toList();

    if (numbers.isEmpty) return;

    numbers.sort();
    int count = numbers.length;
    double sum = numbers.reduce((a, b) => a + b);
    double mean = sum / count;

    // Median
    double median = 0;
    if (count % 2 == 1) {
      median = numbers[count ~/ 2];
    } else {
      median = (numbers[(count ~/ 2) - 1] + numbers[count ~/ 2]) / 2;
    }

    // Mode
    Map<double, int> freq = {};
    for (var n in numbers) {
      freq[n] = (freq[n] ?? 0) + 1;
    }
    int maxFreq = freq.values.reduce(max);
    List<double> modes = freq.entries.where((e) => e.value == maxFreq && maxFreq > 1).map((e) => e.key).toList();

    // Standard Deviation
    double variance = numbers.map((x) => pow(x - mean, 2)).reduce((a, b) => a + b) / count;
    double stdDev = sqrt(variance);

    setState(() {
      _count = count;
      _mean = mean;
      _median = median;
      _mode = modes.isEmpty ? 'N/A' : modes.join(', ');
      _stdDev = stdDev;
    });
  }

  @override
  Widget build(BuildContext context) {
    final langNotifier = ref.watch(languageProvider.notifier);
    final lang = ref.watch(languageProvider);
    final tool = ToolCategories.getToolById('statistics_calc');

    return Scaffold(
      appBar: AppBar(title: Text(tool.getTitle(lang)), centerTitle: true),
      body: ResponsiveContainer(
        maxWidth: 700,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: Colors.blueGrey.shade900,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text('${langNotifier.translate('data_count')}: $_count', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(children: [Text(langNotifier.translate('mean_label'), style: const TextStyle(color: Colors.white70)), Text(_mean.toStringAsFixed(2), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.amberAccent))]),
                        Column(children: [Text(langNotifier.translate('median_label'), style: const TextStyle(color: Colors.white70)), Text(_median.toStringAsFixed(2), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.greenAccent))]),
                      ],
                    ),
                    const Divider(color: Colors.white24, height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(children: [Text(langNotifier.translate('mode_label'), style: const TextStyle(color: Colors.white70)), Text(_mode, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white))]),
                        Column(children: [Text(langNotifier.translate('std_dev_label'), style: const TextStyle(color: Colors.white70)), Text(_stdDev.toStringAsFixed(2), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.lightBlueAccent))]),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _dataCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: langNotifier.translate('enter_numbers_hint'),
                    border: const OutlineInputBorder(),
                  ),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/tool_categories.dart';
import '../../../../core/localization/localization_provider.dart';
import '../../../common/widgets/responsive_container.dart';

class RatioCalculatorScreen extends ConsumerStatefulWidget {
  const RatioCalculatorScreen({super.key});

  @override
  ConsumerState<RatioCalculatorScreen> createState() => _RatioCalculatorScreenState();
}

class _RatioCalculatorScreenState extends ConsumerState<RatioCalculatorScreen> {
  final TextEditingController _aCtrl = TextEditingController(text: '4');
  final TextEditingController _bCtrl = TextEditingController(text: '8');
  final TextEditingController _cCtrl = TextEditingController(text: '12');

  double _xRatioResult = 24.0;

  void _calculate() {
    double a = double.tryParse(_aCtrl.text) ?? 1;
    double b = double.tryParse(_bCtrl.text) ?? 1;
    double c = double.tryParse(_cCtrl.text) ?? 1;

    if (a == 0) return;
    setState(() => _xRatioResult = (b * c) / a);
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final tool = ToolCategories.getToolById('ratio_calc');

    return Scaffold(
      appBar: AppBar(title: Text(tool.getTitle(lang)), centerTitle: true),
      body: ResponsiveContainer(
        maxWidth: 700,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: Colors.teal.shade900,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text('Proportion A : B = C : X', style: TextStyle(color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text('X = ${_xRatioResult.toStringAsFixed(2)}', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.amberAccent)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(controller: _aCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'A Value', border: OutlineInputBorder()), onChanged: (_) => _calculate()),
                    const SizedBox(height: 12),
                    TextField(controller: _bCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'B Value', border: OutlineInputBorder()), onChanged: (_) => _calculate()),
                    const SizedBox(height: 12),
                    TextField(controller: _cCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'C Value', border: OutlineInputBorder()), onChanged: (_) => _calculate()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

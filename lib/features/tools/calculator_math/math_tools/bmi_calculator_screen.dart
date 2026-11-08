import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/tool_categories.dart';
import '../../../../core/localization/localization_provider.dart';
import '../../../common/widgets/responsive_container.dart';

class BmiCalculatorScreen extends ConsumerStatefulWidget {
  const BmiCalculatorScreen({super.key});

  @override
  ConsumerState<BmiCalculatorScreen> createState() => _BmiCalculatorScreenState();
}

class _BmiCalculatorScreenState extends ConsumerState<BmiCalculatorScreen> {
  final TextEditingController _weightKgCtrl = TextEditingController(text: '68');
  final TextEditingController _heightCmCtrl = TextEditingController(text: '172');

  double _bmiValue = 23.0;
  String _bmiCategoryKey = 'normal_weight';

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    double w = double.tryParse(_weightKgCtrl.text) ?? 0;
    double cm = double.tryParse(_heightCmCtrl.text) ?? 0;

    if (w <= 0 || cm <= 0) return;

    double meters = cm / 100;
    double bmi = w / (meters * meters);

    String key = 'normal_weight';
    if (bmi < 18.5) {
      key = 'underweight';
    } else if (bmi >= 18.5 && bmi < 24.9) {
      key = 'normal_weight';
    } else if (bmi >= 25 && bmi < 29.9) {
      key = 'overweight';
    } else {
      key = 'obese';
    }

    setState(() {
      _bmiValue = bmi;
      _bmiCategoryKey = key;
    });
  }

  @override
  Widget build(BuildContext context) {
    final langNotifier = ref.watch(languageProvider.notifier);
    final lang = ref.watch(languageProvider);
    final tool = ToolCategories.getToolById('bmi_calc');

    return Scaffold(
      appBar: AppBar(title: Text(tool.getTitle(lang)), centerTitle: true),
      body: ResponsiveContainer(
        maxWidth: 700,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: Colors.teal.shade800,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(langNotifier.translate('body_mass_index'), style: const TextStyle(color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      _bmiValue.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.amberAccent),
                    ),
                    const SizedBox(height: 4),
                    Text(langNotifier.translate(_bmiCategoryKey), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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
                    TextField(
                      controller: _weightKgCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: langNotifier.translate('weight_kg'), border: const OutlineInputBorder()),
                      onChanged: (_) => _calculate(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _heightCmCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: langNotifier.translate('height_cm'), border: const OutlineInputBorder()),
                      onChanged: (_) => _calculate(),
                    ),
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

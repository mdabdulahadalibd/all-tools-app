import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/tool_categories.dart';
import '../../../../core/localization/localization_provider.dart';
import '../../../common/widgets/responsive_container.dart';

class BmrCalculatorScreen extends ConsumerStatefulWidget {
  const BmrCalculatorScreen({super.key});

  @override
  ConsumerState<BmrCalculatorScreen> createState() => _BmrCalculatorScreenState();
}

class _BmrCalculatorScreenState extends ConsumerState<BmrCalculatorScreen> {
  final TextEditingController _wCtrl = TextEditingController(text: '70');
  final TextEditingController _hCtrl = TextEditingController(text: '172');
  final TextEditingController _aCtrl = TextEditingController(text: '25');
  bool _isMale = true;

  double _bmrValue = 1650.0;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    double w = double.tryParse(_wCtrl.text) ?? 70;
    double h = double.tryParse(_hCtrl.text) ?? 172;
    double a = double.tryParse(_aCtrl.text) ?? 25;

    // Harris-Benedict Equation
    double bmr = _isMale
        ? 88.362 + (13.397 * w) + (4.799 * h) - (5.677 * a)
        : 447.593 + (9.247 * w) + (3.098 * h) - (4.330 * a);

    setState(() => _bmrValue = bmr);
  }

  @override
  Widget build(BuildContext context) {
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
              color: Colors.deepPurple.shade900,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text('Basal Metabolic Rate (BMR)', style: TextStyle(color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      '${_bmrValue.toStringAsFixed(0)} kcal / day',
                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.amberAccent),
                    ),
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
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Male'),
                            selected: _isMale,
                            onSelected: (v) {
                              if (v) {
                                setState(() => _isMale = true);
                                _calculate();
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Female'),
                            selected: !_isMale,
                            onSelected: (v) {
                              if (v) {
                                setState(() => _isMale = false);
                                _calculate();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _wCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Weight (kg)', border: OutlineInputBorder()),
                      onChanged: (_) => _calculate(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _hCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Height (cm)', border: OutlineInputBorder()),
                      onChanged: (_) => _calculate(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _aCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Age (Years)', border: OutlineInputBorder()),
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

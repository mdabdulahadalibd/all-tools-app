import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/tool_categories.dart';
import '../../../../../core/localization/localization_provider.dart';
import '../../../../common/widgets/responsive_container.dart';

class IdealWeightScreen extends ConsumerStatefulWidget {
  const IdealWeightScreen({super.key});

  @override
  ConsumerState<IdealWeightScreen> createState() => _IdealWeightScreenState();
}

class _IdealWeightScreenState extends ConsumerState<IdealWeightScreen> {
  final TextEditingController _heightCmCtrl = TextEditingController(text: '172');
  bool _isMale = true;

  double _idealWeightKg = 67.0;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    double cm = double.tryParse(_heightCmCtrl.text) ?? 0;
    if (cm <= 0) return;

    double inchesOver5Feet = ((cm / 2.54) - 60).clamp(0, 100);

    // Devine Formula
    double ibw = _isMale ? 50.0 + (2.3 * inchesOver5Feet) : 45.5 + (2.3 * inchesOver5Feet);

    setState(() => _idealWeightKg = ibw);
  }

  @override
  Widget build(BuildContext context) {
    final langNotifier = ref.watch(languageProvider.notifier);
    final lang = ref.watch(languageProvider);
    final tool = ToolCategories.getToolById('ideal_body_weight_calc');

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
                    Text(langNotifier.translate('ideal_weight_est'), style: const TextStyle(color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      '${_idealWeightKg.toStringAsFixed(1)} kg',
                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.amberAccent),
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
                            label: Text(langNotifier.translate('male')),
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
                            label: Text(langNotifier.translate('female')),
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
                    const SizedBox(height: 16),
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

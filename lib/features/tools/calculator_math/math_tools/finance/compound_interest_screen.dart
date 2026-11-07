import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/tool_categories.dart';
import '../../../../../core/localization/localization_provider.dart';
import '../../../../common/widgets/responsive_container.dart';

class CompoundInterestScreen extends ConsumerStatefulWidget {
  const CompoundInterestScreen({super.key});

  @override
  ConsumerState<CompoundInterestScreen> createState() => _CompoundInterestScreenState();
}

class _CompoundInterestScreenState extends ConsumerState<CompoundInterestScreen> {
  final TextEditingController _principalCtrl = TextEditingController(text: '100000');
  final TextEditingController _rateCtrl = TextEditingController(text: '8.5');
  final TextEditingController _yearsCtrl = TextEditingController(text: '5');
  int _frequency = 1;

  double _totalAmount = 0.0;
  double _totalInterest = 0.0;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    double p = double.tryParse(_principalCtrl.text) ?? 0;
    double r = (double.tryParse(_rateCtrl.text) ?? 0) / 100;
    double t = double.tryParse(_yearsCtrl.text) ?? 0;
    int n = _frequency;

    if (p <= 0 || r <= 0 || t <= 0) {
      setState(() {
        _totalAmount = 0;
        _totalInterest = 0;
      });
      return;
    }

    double amount = p * pow((1 + (r / n)), (n * t));
    setState(() {
      _totalAmount = amount;
      _totalInterest = amount - p;
    });
  }

  @override
  Widget build(BuildContext context) {
    final langNotifier = ref.watch(languageProvider.notifier);
    final lang = ref.watch(languageProvider);
    final tool = ToolCategories.getToolById('compound_interest_calc');

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
                    Text(langNotifier.translate('total_future_return'), style: const TextStyle(color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      '৳ ${_totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.greenAccent),
                    ),
                    const Divider(color: Colors.white24, height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(langNotifier.translate('principal_amount'), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            Text('৳ ${_principalCtrl.text}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        Column(
                          children: [
                            Text(langNotifier.translate('total_interest'), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            Text('৳ ${_totalInterest.toStringAsFixed(2)}', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
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
                child: Column(
                  children: [
                    TextField(
                      controller: _principalCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: langNotifier.translate('initial_principal_deposit'), border: const OutlineInputBorder()),
                      onChanged: (_) => _calculate(),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _rateCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(labelText: langNotifier.translate('interest_rate_pa'), border: const OutlineInputBorder()),
                            onChanged: (_) => _calculate(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _yearsCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(labelText: langNotifier.translate('time_period_years'), border: const OutlineInputBorder()),
                            onChanged: (_) => _calculate(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      initialValue: _frequency,
                      decoration: InputDecoration(labelText: langNotifier.translate('compounding_frequency'), border: const OutlineInputBorder()),
                      items: [
                        DropdownMenuItem(value: 1, child: Text(langNotifier.translate('annually'))),
                        DropdownMenuItem(value: 4, child: Text(langNotifier.translate('quarterly'))),
                        DropdownMenuItem(value: 12, child: Text(langNotifier.translate('monthly'))),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _frequency = val);
                          _calculate();
                        }
                      },
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

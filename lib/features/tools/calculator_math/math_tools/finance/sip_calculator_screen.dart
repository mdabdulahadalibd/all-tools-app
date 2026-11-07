import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/tool_categories.dart';
import '../../../../../core/localization/localization_provider.dart';
import '../../../../common/widgets/responsive_container.dart';

class SipCalculatorScreen extends ConsumerStatefulWidget {
  const SipCalculatorScreen({super.key});

  @override
  ConsumerState<SipCalculatorScreen> createState() => _SipCalculatorScreenState();
}

class _SipCalculatorScreenState extends ConsumerState<SipCalculatorScreen> {
  final TextEditingController _monthlyInvestCtrl = TextEditingController(text: '5000');
  final TextEditingController _returnRateCtrl = TextEditingController(text: '12');
  final TextEditingController _yearsCtrl = TextEditingController(text: '10');

  double _totalInvested = 0.0;
  double _estimatedReturn = 0.0;
  double _totalMaturityValue = 0.0;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    double p = double.tryParse(_monthlyInvestCtrl.text) ?? 0;
    double i = (double.tryParse(_returnRateCtrl.text) ?? 0) / 12 / 100;
    double n = (double.tryParse(_yearsCtrl.text) ?? 0) * 12;

    if (p <= 0 || i <= 0 || n <= 0) return;

    double maturity = p * ((pow(1 + i, n) - 1) / i) * (1 + i);
    double invested = p * n;

    setState(() {
      _totalInvested = invested;
      _totalMaturityValue = maturity;
      _estimatedReturn = maturity - invested;
    });
  }

  @override
  Widget build(BuildContext context) {
    final langNotifier = ref.watch(languageProvider.notifier);
    final lang = ref.watch(languageProvider);
    final tool = ToolCategories.getToolById('sip_mutual_fund_calc');

    return Scaffold(
      appBar: AppBar(title: Text(tool.getTitle(lang)), centerTitle: true),
      body: ResponsiveContainer(
        maxWidth: 700,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: Colors.green.shade900,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(langNotifier.translate('total_expected_wealth'), style: const TextStyle(color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      '৳ ${_totalMaturityValue.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.greenAccent),
                    ),
                    const Divider(color: Colors.white24, height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(langNotifier.translate('invested_amount'), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            Text('৳ ${_totalInvested.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        Column(
                          children: [
                            Text(langNotifier.translate('estimated_wealth_gain'), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            Text('৳ ${_estimatedReturn.toStringAsFixed(2)}', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16)),
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
                      controller: _monthlyInvestCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: langNotifier.translate('monthly_investment_amount'), border: const OutlineInputBorder()),
                      onChanged: (_) => _calculate(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _returnRateCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: langNotifier.translate('expected_annual_return'), border: const OutlineInputBorder()),
                      onChanged: (_) => _calculate(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _yearsCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: langNotifier.translate('investment_tenure_years'), border: const OutlineInputBorder()),
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

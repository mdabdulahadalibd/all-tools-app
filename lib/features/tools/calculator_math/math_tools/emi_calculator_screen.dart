import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/tool_categories.dart';
import '../../../../core/localization/localization_provider.dart';
import '../../../common/widgets/responsive_container.dart';

class EmiCalculatorScreen extends ConsumerStatefulWidget {
  const EmiCalculatorScreen({super.key});

  @override
  ConsumerState<EmiCalculatorScreen> createState() => _EmiCalculatorScreenState();
}

class _EmiCalculatorScreenState extends ConsumerState<EmiCalculatorScreen> {
  final TextEditingController _loanAmountCtrl = TextEditingController(text: '500000');
  final TextEditingController _rateCtrl = TextEditingController(text: '9.5');
  final TextEditingController _tenureYearsCtrl = TextEditingController(text: '5');

  double _monthlyEmi = 0.0;
  double _totalInterest = 0.0;
  double _totalPayment = 0.0;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    double p = double.tryParse(_loanAmountCtrl.text) ?? 0;
    double annualRate = double.tryParse(_rateCtrl.text) ?? 0;
    double years = double.tryParse(_tenureYearsCtrl.text) ?? 0;

    if (p <= 0 || annualRate <= 0 || years <= 0) return;

    double r = annualRate / 12 / 100;
    double n = years * 12;

    double emi = (p * r * pow(1 + r, n)) / (pow(1 + r, n) - 1);
    double totalPay = emi * n;

    setState(() {
      _monthlyEmi = emi;
      _totalPayment = totalPay;
      _totalInterest = totalPay - p;
    });
  }

  @override
  Widget build(BuildContext context) {
    final langNotifier = ref.watch(languageProvider.notifier);
    final lang = ref.watch(languageProvider);
    final tool = ToolCategories.getToolById('emi_calc');

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
                    Text(langNotifier.translate('monthly_installment_emi'), style: const TextStyle(color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      '৳ ${_monthlyEmi.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: Colors.greenAccent),
                    ),
                    const Divider(color: Colors.white24, height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(children: [Text(langNotifier.translate('total_interest'), style: const TextStyle(color: Colors.white70, fontSize: 12)), Text('৳ ${_totalInterest.toStringAsFixed(0)}', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16))]),
                        Column(children: [Text(langNotifier.translate('total_payment'), style: const TextStyle(color: Colors.white70, fontSize: 12)), Text('৳ ${_totalPayment.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))]),
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
                      controller: _loanAmountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: langNotifier.translate('loan_principal'), border: const OutlineInputBorder()),
                      onChanged: (_) => _calculate(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _rateCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: langNotifier.translate('interest_rate_pa'), border: const OutlineInputBorder()),
                      onChanged: (_) => _calculate(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _tenureYearsCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: langNotifier.translate('loan_tenure'), border: const OutlineInputBorder()),
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

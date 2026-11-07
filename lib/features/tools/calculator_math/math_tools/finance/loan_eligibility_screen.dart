import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/tool_categories.dart';
import '../../../../../core/localization/localization_provider.dart';
import '../../../../common/widgets/responsive_container.dart';

class LoanEligibilityScreen extends ConsumerStatefulWidget {
  const LoanEligibilityScreen({super.key});

  @override
  ConsumerState<LoanEligibilityScreen> createState() => _LoanEligibilityScreenState();
}

class _LoanEligibilityScreenState extends ConsumerState<LoanEligibilityScreen> {
  final TextEditingController _incomeCtrl = TextEditingController(text: '80000');
  final TextEditingController _existingEmiCtrl = TextEditingController(text: '10000');
  final TextEditingController _rateCtrl = TextEditingController(text: '9');
  final TextEditingController _tenureYearsCtrl = TextEditingController(text: '15');

  double _maxEligibleEmi = 0.0;
  double _maxLoanAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    double income = double.tryParse(_incomeCtrl.text) ?? 0;
    double existingEmi = double.tryParse(_existingEmiCtrl.text) ?? 0;
    double rateAnnual = double.tryParse(_rateCtrl.text) ?? 0;
    double years = double.tryParse(_tenureYearsCtrl.text) ?? 0;

    double maxAllowedEmiPercent = 0.50;
    double maxEmiCapacity = (income * maxAllowedEmiPercent) - existingEmi;

    if (maxEmiCapacity <= 0 || rateAnnual <= 0 || years <= 0) {
      setState(() {
        _maxEligibleEmi = 0;
        _maxLoanAmount = 0;
      });
      return;
    }

    double r = rateAnnual / 12 / 100;
    double n = years * 12;

    double loanP = maxEmiCapacity * (pow(1 + r, n) - 1) / (r * pow(1 + r, n));

    setState(() {
      _maxEligibleEmi = maxEmiCapacity;
      _maxLoanAmount = loanP;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final tool = ToolCategories.getToolById('loan_eligibility_calc');

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
                    const Text('Maximum Eligible Loan Amount', style: TextStyle(color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      '৳ ${_maxLoanAmount.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.lightGreenAccent),
                    ),
                    const Divider(color: Colors.white24, height: 24),
                    Text(
                      'Max Affordable Monthly EMI: ৳ ${_maxEligibleEmi.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
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
                      controller: _incomeCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Monthly Net Income (৳)', border: OutlineInputBorder()),
                      onChanged: (_) => _calculate(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _existingEmiCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Existing Monthly EMIs / Obligations (৳)', border: OutlineInputBorder()),
                      onChanged: (_) => _calculate(),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _rateCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Expected Rate (% p.a.)', border: OutlineInputBorder()),
                            onChanged: (_) => _calculate(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _tenureYearsCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Tenure (Years)', border: OutlineInputBorder()),
                            onChanged: (_) => _calculate(),
                          ),
                        ),
                      ],
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

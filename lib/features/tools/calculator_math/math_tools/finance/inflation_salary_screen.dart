import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/tool_categories.dart';
import '../../../../../core/localization/localization_provider.dart';
import '../../../../common/widgets/responsive_container.dart';

class InflationSalaryScreen extends ConsumerStatefulWidget {
  const InflationSalaryScreen({super.key});

  @override
  ConsumerState<InflationSalaryScreen> createState() => _InflationSalaryScreenState();
}

class _InflationSalaryScreenState extends ConsumerState<InflationSalaryScreen> {
  final TextEditingController _currentSalaryCtrl = TextEditingController(text: '50000');
  final TextEditingController _inflationRateCtrl = TextEditingController(text: '6.5');
  final TextEditingController _yearsCtrl = TextEditingController(text: '10');

  double _futureRequiredSalary = 0.0;
  double _purchasingPower = 0.0;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    double salary = double.tryParse(_currentSalaryCtrl.text) ?? 0;
    double rate = (double.tryParse(_inflationRateCtrl.text) ?? 0) / 100;
    double years = double.tryParse(_yearsCtrl.text) ?? 0;

    if (salary <= 0 || years <= 0) return;

    double futureNeeded = salary * pow(1 + rate, years);
    double power = salary / pow(1 + rate, years);

    setState(() {
      _futureRequiredSalary = futureNeeded;
      _purchasingPower = power;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final tool = ToolCategories.getToolById('inflation_salary_calc');

    return Scaffold(
      appBar: AppBar(title: Text(tool.getTitle(lang)), centerTitle: true),
      body: ResponsiveContainer(
        maxWidth: 700,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: Colors.purple.shade900,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text('Required Future Salary in ${_yearsCtrl.text} Years', style: const TextStyle(color: Colors.white70, fontSize: 15)),
                    const SizedBox(height: 8),
                    Text(
                      '৳ ${_futureRequiredSalary.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.amberAccent),
                    ),
                    const Divider(color: Colors.white24, height: 24),
                    Text(
                      'Purchasing Power of Today\'s ৳ ${_currentSalaryCtrl.text}: ৳ ${_purchasingPower.toStringAsFixed(0)}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold),
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
                      controller: _currentSalaryCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Current Monthly Expenses / Salary (৳)', border: OutlineInputBorder()),
                      onChanged: (_) => _calculate(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _inflationRateCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Expected Inflation Rate (% p.a.)', border: OutlineInputBorder()),
                      onChanged: (_) => _calculate(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _yearsCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Time Horizon (Years)', border: OutlineInputBorder()),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/tool_categories.dart';
import '../../../../core/localization/localization_provider.dart';
import '../../../common/widgets/responsive_container.dart';

class FractionCalculatorScreen extends ConsumerStatefulWidget {
  const FractionCalculatorScreen({super.key});

  @override
  ConsumerState<FractionCalculatorScreen> createState() => _FractionCalculatorScreenState();
}

class _FractionCalculatorScreenState extends ConsumerState<FractionCalculatorScreen> {
  final TextEditingController _num1Ctrl = TextEditingController(text: '1');
  final TextEditingController _den1Ctrl = TextEditingController(text: '2');
  final TextEditingController _num2Ctrl = TextEditingController(text: '1');
  final TextEditingController _den2Ctrl = TextEditingController(text: '4');

  String _resultFraction = '3 / 4';

  void _calculate() {
    int n1 = int.tryParse(_num1Ctrl.text) ?? 1;
    int d1 = int.tryParse(_den1Ctrl.text) ?? 1;
    int n2 = int.tryParse(_num2Ctrl.text) ?? 1;
    int d2 = int.tryParse(_den2Ctrl.text) ?? 1;

    if (d1 == 0 || d2 == 0) return;

    int numAns = (n1 * d2) + (n2 * d1);
    int denAns = d1 * d2;

    int gcdVal = _gcd(numAns, denAns);
    numAns ~/= gcdVal;
    denAns ~/= gcdVal;

    setState(() => _resultFraction = '$numAns / $denAns');
  }

  int _gcd(int a, int b) {
    while (b != 0) {
      var t = b;
      b = a % b;
      a = t;
    }
    return a;
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final tool = ToolCategories.getToolById('fraction_calc');

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
                    const Text('Sum Fraction Result', style: TextStyle(color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(_resultFraction, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.amberAccent)),
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
                        Expanded(child: TextField(controller: _num1Ctrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Numerator 1', border: OutlineInputBorder()), onChanged: (_) => _calculate())),
                        const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('/', style: TextStyle(fontSize: 24))),
                        Expanded(child: TextField(controller: _den1Ctrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Denominator 1', border: OutlineInputBorder()), onChanged: (_) => _calculate())),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: _num2Ctrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Numerator 2', border: OutlineInputBorder()), onChanged: (_) => _calculate())),
                        const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('/', style: TextStyle(fontSize: 24))),
                        Expanded(child: TextField(controller: _den2Ctrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Denominator 2', border: OutlineInputBorder()), onChanged: (_) => _calculate())),
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

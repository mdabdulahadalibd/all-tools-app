import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../common/widgets/responsive_container.dart';

class ApGpSeriesScreen extends StatefulWidget {
  const ApGpSeriesScreen({super.key});

  @override
  State<ApGpSeriesScreen> createState() => _ApGpSeriesScreenState();
}

class _ApGpSeriesScreenState extends State<ApGpSeriesScreen> {
  bool _isAp = true; // true = AP (Arithmetic), false = GP (Geometric)
  final TextEditingController _firstTermCtrl = TextEditingController(text: '2');
  final TextEditingController _diffRatioCtrl = TextEditingController(text: '3');
  final TextEditingController _nTermsCtrl = TextEditingController(text: '10');

  double _nthTerm = 0.0;
  double _sumN = 0.0;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    double a = double.tryParse(_firstTermCtrl.text) ?? 0;
    double dOrR = double.tryParse(_diffRatioCtrl.text) ?? 0;
    double n = double.tryParse(_nTermsCtrl.text) ?? 0;

    if (n <= 0) return;

    if (_isAp) {
      double nth = a + (n - 1) * dOrR;
      double sum = (n / 2) * (2 * a + (n - 1) * dOrR);
      setState(() {
        _nthTerm = nth;
        _sumN = sum;
      });
    } else {
      double r = dOrR;
      double nth = a * pow(r, n - 1);
      double sum = (r != 1) ? a * (pow(r, n) - 1) / (r - 1) : a * n;
      setState(() {
        _nthTerm = nth;
        _sumN = sum;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AP & GP Series Calculator')),
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
                    Text(_isAp ? 'Arithmetic Progression (AP)' : 'Geometric Progression (GP)', style: const TextStyle(color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 12),
                    Text('${_nTermsCtrl.text}-th Term: ${_nthTerm.toStringAsFixed(2)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.amberAccent)),
                    const SizedBox(height: 6),
                    Text('Sum of ${_nTermsCtrl.text} Terms: ${_sumN.toStringAsFixed(2)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.lightGreenAccent)),
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
                            label: const Text('Arithmetic (AP)'),
                            selected: _isAp,
                            onSelected: (v) {
                              if (v) {
                                setState(() => _isAp = true);
                                _calculate();
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Geometric (GP)'),
                            selected: !_isAp,
                            onSelected: (v) {
                              if (v) {
                                setState(() => _isAp = false);
                                _calculate();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _firstTermCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'First Term (a)', border: OutlineInputBorder()),
                      onChanged: (_) => _calculate(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _diffRatioCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: _isAp ? 'Common Difference (d)' : 'Common Ratio (r)', border: const OutlineInputBorder()),
                      onChanged: (_) => _calculate(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nTermsCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Number of Terms (n)', border: OutlineInputBorder()),
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

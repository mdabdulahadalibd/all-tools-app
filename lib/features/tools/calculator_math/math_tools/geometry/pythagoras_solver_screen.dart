import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../common/widgets/responsive_container.dart';

class PythagorasSolverScreen extends StatefulWidget {
  const PythagorasSolverScreen({super.key});

  @override
  State<PythagorasSolverScreen> createState() => _PythagorasSolverScreenState();
}

class _PythagorasSolverScreenState extends State<PythagorasSolverScreen> {
  final TextEditingController _aCtrl = TextEditingController(text: '3');
  final TextEditingController _bCtrl = TextEditingController(text: '4');

  double _hypotenuseC = 5.0;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    double a = double.tryParse(_aCtrl.text) ?? 0;
    double b = double.tryParse(_bCtrl.text) ?? 0;

    if (a <= 0 || b <= 0) return;

    double c = sqrt((a * a) + (b * b));
    setState(() => _hypotenuseC = c);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pythagoras Theorem Solver')),
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
                    const Text('Hypotenuse c = √(a² + b²)', style: TextStyle(color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      _hypotenuseC.toStringAsFixed(2),
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
                    TextField(
                      controller: _aCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Perpendicular Side (a)', border: OutlineInputBorder()),
                      onChanged: (_) => _calculate(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _bCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Base Side (b)', border: OutlineInputBorder()),
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

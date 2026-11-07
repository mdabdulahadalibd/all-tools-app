import 'package:flutter/material.dart';
import '../../../../common/widgets/responsive_container.dart';

class MatrixCalculatorScreen extends StatefulWidget {
  const MatrixCalculatorScreen({super.key});

  @override
  State<MatrixCalculatorScreen> createState() => _MatrixCalculatorScreenState();
}

class _MatrixCalculatorScreenState extends State<MatrixCalculatorScreen> {
  // 2x2 Matrix inputs: a, b, c, d
  double _a = 2, _b = 3, _c = 1, _d = 4;

  double get _determinant => (_a * _d) - (_b * _c);

  @override
  Widget build(BuildContext context) {
    double det = _determinant;

    return Scaffold(
      appBar: AppBar(title: const Text('2x2 Matrix & Determinant Solver')),
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
                    const Text('Determinant |A|', style: TextStyle(color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      det.toStringAsFixed(2),
                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.amberAccent),
                    ),
                    const Divider(color: Colors.white24, height: 24),
                    Text(
                      det != 0
                          ? 'Inverse Matrix A⁻¹ exists:\n[  ${(_d / det).toStringAsFixed(2)}   ${(-_b / det).toStringAsFixed(2)}  ]\n[  ${(-_c / det).toStringAsFixed(2)}   ${(_a / det).toStringAsFixed(2)}  ]'
                          : 'Singular Matrix (Determinant = 0, Inverse does not exist)',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold),
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
                    const Text('Matrix A Elements [ a  b / c  d ]', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: TextEditingController(text: '$_a'),
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'a (row 1, col 1)', border: OutlineInputBorder()),
                            onChanged: (v) => setState(() => _a = double.tryParse(v) ?? 0),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: TextEditingController(text: '$_b'),
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'b (row 1, col 2)', border: OutlineInputBorder()),
                            onChanged: (v) => setState(() => _b = double.tryParse(v) ?? 0),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: TextEditingController(text: '$_c'),
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'c (row 2, col 1)', border: OutlineInputBorder()),
                            onChanged: (v) => setState(() => _c = double.tryParse(v) ?? 0),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: TextEditingController(text: '$_d'),
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'd (row 2, col 2)', border: OutlineInputBorder()),
                            onChanged: (v) => setState(() => _d = double.tryParse(v) ?? 0),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/tool_categories.dart';
import '../../../../core/localization/localization_provider.dart';
import '../../../common/widgets/responsive_container.dart';

class EquationSolverScreen extends ConsumerStatefulWidget {
  const EquationSolverScreen({super.key});

  @override
  ConsumerState<EquationSolverScreen> createState() => _EquationSolverScreenState();
}

class _EquationSolverScreenState extends ConsumerState<EquationSolverScreen> {
  final TextEditingController _aCtrl = TextEditingController(text: '2');
  final TextEditingController _bCtrl = TextEditingController(text: '8');

  double _xVal = -4.0;

  void _solve() {
    double a = double.tryParse(_aCtrl.text) ?? 1;
    double b = double.tryParse(_bCtrl.text) ?? 0;

    if (a == 0) return;
    setState(() => _xVal = -b / a);
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final tool = ToolCategories.getToolById('equation_solver');

    return Scaffold(
      appBar: AppBar(title: Text(tool.getTitle(lang)), centerTitle: true),
      body: ResponsiveContainer(
        maxWidth: 700,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: Colors.deepPurple.shade900,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text('Linear Equation: ax + b = 0', style: TextStyle(color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text('x = ${_xVal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: Colors.amberAccent)),
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
                    TextField(controller: _aCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Coefficient a (a ≠ 0)', border: OutlineInputBorder()), onChanged: (_) => _solve()),
                    const SizedBox(height: 12),
                    TextField(controller: _bCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Constant b', border: OutlineInputBorder()), onChanged: (_) => _solve()),
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

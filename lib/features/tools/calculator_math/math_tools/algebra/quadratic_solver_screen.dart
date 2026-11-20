import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/tool_categories.dart';
import '../../../../../core/localization/localization_provider.dart';
import '../../../../common/widgets/responsive_container.dart';

class QuadraticSolverScreen extends ConsumerStatefulWidget {
  const QuadraticSolverScreen({super.key});

  @override
  ConsumerState<QuadraticSolverScreen> createState() => _QuadraticSolverScreenState();
}

class _QuadraticSolverScreenState extends ConsumerState<QuadraticSolverScreen> {
  final TextEditingController _aCtrl = TextEditingController(text: '1');
  final TextEditingController _bCtrl = TextEditingController(text: '-5');
  final TextEditingController _cCtrl = TextEditingController(text: '6');

  String _root1Str = 'x₁ = 3';
  String _root2Str = 'x₂ = 2';
  double _discriminant = 1;

  @override
  void initState() {
    super.initState();
    _solve();
  }

  void _solve() {
    double a = double.tryParse(_aCtrl.text) ?? 1;
    double b = double.tryParse(_bCtrl.text) ?? 0;
    double c = double.tryParse(_cCtrl.text) ?? 0;

    if (a == 0) {
      setState(() {
        _root1Str = 'a ≠ 0';
        _root2Str = '';
      });
      return;
    }

    double d = (b * b) - (4 * a * c);
    setState(() => _discriminant = d);

    if (d > 0) {
      double r1 = (-b + sqrt(d)) / (2 * a);
      double r2 = (-b - sqrt(d)) / (2 * a);
      setState(() {
        _root1Str = 'x₁ = ${r1.toStringAsFixed(4)}';
        _root2Str = 'x₂ = ${r2.toStringAsFixed(4)}';
      });
    } else if (d == 0) {
      double r = -b / (2 * a);
      setState(() {
        _root1Str = 'x = ${r.toStringAsFixed(4)}';
        _root2Str = '';
      });
    } else {
      double realPart = -b / (2 * a);
      double imagPart = sqrt(-d) / (2 * a);
      setState(() {
        _root1Str = 'x₁ = ${realPart.toStringAsFixed(2)} + ${imagPart.toStringAsFixed(2)}i';
        _root2Str = 'x₂ = ${realPart.toStringAsFixed(2)} - ${imagPart.toStringAsFixed(2)}i';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final langNotifier = ref.watch(languageProvider.notifier);
    final lang = ref.watch(languageProvider);
    final tool = ToolCategories.getToolById('quadratic_equation_solver');

    return Scaffold(
      appBar: AppBar(title: Text(tool.getTitle(lang)), centerTitle: true),
      body: ResponsiveContainer(
        maxWidth: 700,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: Colors.cyan.shade900,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(langNotifier.translate('equation_quadratic'), style: const TextStyle(color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 12),
                    Text(_root1Str, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.amberAccent)),
                    if (_root2Str.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(_root2Str, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                    ],
                    const Divider(color: Colors.white24, height: 24),
                    Text(
                      '${langNotifier.translate('discriminant')}: ${_discriminant.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                      decoration: InputDecoration(labelText: langNotifier.translate('coeff_a'), border: const OutlineInputBorder()),
                      onChanged: (_) => _solve(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _bCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: langNotifier.translate('coeff_b'), border: const OutlineInputBorder()),
                      onChanged: (_) => _solve(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _cCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: langNotifier.translate('constant_c'), border: const OutlineInputBorder()),
                      onChanged: (_) => _solve(),
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

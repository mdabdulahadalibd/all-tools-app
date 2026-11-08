import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/tool_categories.dart';
import '../../../../../core/localization/localization_provider.dart';
import '../../../../common/widgets/responsive_container.dart';

class TrigonometrySolverScreen extends ConsumerStatefulWidget {
  const TrigonometrySolverScreen({super.key});

  @override
  ConsumerState<TrigonometrySolverScreen> createState() => _TrigonometrySolverScreenState();
}

class _TrigonometrySolverScreenState extends ConsumerState<TrigonometrySolverScreen> {
  final TextEditingController _angleCtrl = TextEditingController(text: '45');

  double _sinVal = 0.7071;
  double _cosVal = 0.7071;
  double _tanVal = 1.0000;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    double deg = double.tryParse(_angleCtrl.text) ?? 0;
    double rad = deg * (pi / 180);

    setState(() {
      _sinVal = sin(rad);
      _cosVal = cos(rad);
      _tanVal = (cos(rad).abs() < 0.0001) ? double.nan : tan(rad);
    });
  }

  @override
  Widget build(BuildContext context) {
    final langNotifier = ref.watch(languageProvider.notifier);
    final lang = ref.watch(languageProvider);
    final tool = ToolCategories.getToolById('trigonometry_solver');

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
                    Text('Angle θ = ${_angleCtrl.text}°', style: const TextStyle(color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(children: [const Text('sin(θ)', style: TextStyle(color: Colors.white70)), Text(_sinVal.toStringAsFixed(4), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.amberAccent))]),
                        Column(children: [const Text('cos(θ)', style: TextStyle(color: Colors.white70)), Text(_cosVal.toStringAsFixed(4), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.greenAccent))]),
                        Column(children: [const Text('tan(θ)', style: TextStyle(color: Colors.white70)), Text(_tanVal.isNaN ? 'Undefined' : _tanVal.toStringAsFixed(4), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.lightBlueAccent))]),
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
                child: TextField(
                  controller: _angleCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: langNotifier.translate('angle_degrees'), border: const OutlineInputBorder()),
                  onChanged: (_) => _calculate(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

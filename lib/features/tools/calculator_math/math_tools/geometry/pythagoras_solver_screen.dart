import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/tool_categories.dart';
import '../../../../../core/localization/localization_provider.dart';
import '../../../../common/widgets/responsive_container.dart';

class PythagorasSolverScreen extends ConsumerStatefulWidget {
  const PythagorasSolverScreen({super.key});

  @override
  ConsumerState<PythagorasSolverScreen> createState() => _PythagorasSolverScreenState();
}

class _PythagorasSolverScreenState extends ConsumerState<PythagorasSolverScreen> {
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
    final langNotifier = ref.watch(languageProvider.notifier);
    final lang = ref.watch(languageProvider);
    final tool = ToolCategories.getToolById('pythagoras_triangle_calc');

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
                    Text(langNotifier.translate('hypotenuse'), style: const TextStyle(color: Colors.white70, fontSize: 16)),
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
                      decoration: InputDecoration(labelText: langNotifier.translate('perpendicular_side'), border: const OutlineInputBorder()),
                      onChanged: (_) => _calculate(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _bCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: langNotifier.translate('base_side'), border: const OutlineInputBorder()),
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

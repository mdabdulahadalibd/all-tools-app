import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/tool_categories.dart';
import '../../../../../core/localization/localization_provider.dart';
import '../../../../common/widgets/responsive_container.dart';

class BodyFatScreen extends ConsumerStatefulWidget {
  const BodyFatScreen({super.key});

  @override
  ConsumerState<BodyFatScreen> createState() => _BodyFatScreenState();
}

class _BodyFatScreenState extends ConsumerState<BodyFatScreen> {
  final TextEditingController _waistCmCtrl = TextEditingController(text: '82');
  final TextEditingController _neckCmCtrl = TextEditingController(text: '38');
  final TextEditingController _heightCmCtrl = TextEditingController(text: '172');

  double _bodyFatPercent = 16.5;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    double waist = double.tryParse(_waistCmCtrl.text) ?? 82;
    double neck = double.tryParse(_neckCmCtrl.text) ?? 38;
    double height = double.tryParse(_heightCmCtrl.text) ?? 172;

    if (waist <= neck || height <= 0) return;

    // US Navy Body Fat Formula (Male)
    double fat = 495 / (1.0324 - 0.19077 * (log(waist - neck) / ln10) + 0.15456 * (log(height) / ln10)) - 450;

    setState(() => _bodyFatPercent = fat.clamp(3, 50));
  }

  @override
  Widget build(BuildContext context) {
    final langNotifier = ref.watch(languageProvider.notifier);
    final lang = ref.watch(languageProvider);
    final tool = ToolCategories.getToolById('body_fat_percentage_calc');

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
                    const Text('Estimated Body Fat', style: TextStyle(color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      '${_bodyFatPercent.toStringAsFixed(1)} %',
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
                      controller: _waistCmCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Waist Circumference (cm)', border: OutlineInputBorder()),
                      onChanged: (_) => _calculate(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _neckCmCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Neck Circumference (cm)', border: OutlineInputBorder()),
                      onChanged: (_) => _calculate(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _heightCmCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: langNotifier.translate('height_cm'), border: const OutlineInputBorder()),
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

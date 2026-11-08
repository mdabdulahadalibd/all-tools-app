import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/tool_categories.dart';
import '../../../../../core/localization/localization_provider.dart';
import '../../../../common/widgets/responsive_container.dart';

class WaterIntakeScreen extends ConsumerStatefulWidget {
  const WaterIntakeScreen({super.key});

  @override
  ConsumerState<WaterIntakeScreen> createState() => _WaterIntakeScreenState();
}

class _WaterIntakeScreenState extends ConsumerState<WaterIntakeScreen> {
  final TextEditingController _weightKgCtrl = TextEditingController(text: '68');
  double _waterLiters = 2.4;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    double w = double.tryParse(_weightKgCtrl.text) ?? 68;
    double liters = (w * 35) / 1000;

    setState(() => _waterLiters = liters);
  }

  @override
  Widget build(BuildContext context) {
    final langNotifier = ref.watch(languageProvider.notifier);
    final lang = ref.watch(languageProvider);
    final tool = ToolCategories.getToolById('water_intake_calc');

    return Scaffold(
      appBar: AppBar(title: Text(tool.getTitle(lang)), centerTitle: true),
      body: ResponsiveContainer(
        maxWidth: 700,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: Colors.lightBlue.shade800,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(Icons.water_drop, size: 48, color: Colors.white),
                    const SizedBox(height: 8),
                    Text(langNotifier.translate('daily_water_intake'), style: const TextStyle(color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      '${_waterLiters.toStringAsFixed(1)} Liters / Day',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '(${(_waterLiters * 4).toStringAsFixed(0)} Glasses of 250ml)',
                      style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold),
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
                  controller: _weightKgCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: langNotifier.translate('weight_kg'), border: const OutlineInputBorder()),
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

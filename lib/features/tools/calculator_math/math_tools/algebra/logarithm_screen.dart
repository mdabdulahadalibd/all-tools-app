import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/tool_categories.dart';
import '../../../../../core/localization/localization_provider.dart';
import '../../../../common/widgets/responsive_container.dart';

class LogarithmScreen extends ConsumerStatefulWidget {
  const LogarithmScreen({super.key});

  @override
  ConsumerState<LogarithmScreen> createState() => _LogarithmScreenState();
}

class _LogarithmScreenState extends ConsumerState<LogarithmScreen> {
  final TextEditingController _valCtrl = TextEditingController(text: '100');
  final TextEditingController _baseCtrl = TextEditingController(text: '10');

  double _logBaseValue = 2.0;
  double _lnValue = 4.60517;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    double x = double.tryParse(_valCtrl.text) ?? 0;
    double b = double.tryParse(_baseCtrl.text) ?? 10;

    if (x <= 0 || b <= 0 || b == 1) return;

    double lnX = log(x);
    double logB = log(x) / log(b);

    setState(() {
      _lnValue = lnX;
      _logBaseValue = logB;
    });
  }

  @override
  Widget build(BuildContext context) {
    final langNotifier = ref.watch(languageProvider.notifier);
    final lang = ref.watch(languageProvider);
    final tool = ToolCategories.getToolById('logarithm_calc');

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
                    Text('log base ${_baseCtrl.text} (${_valCtrl.text})', style: const TextStyle(color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      _logBaseValue.toStringAsFixed(6),
                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.amberAccent),
                    ),
                    const Divider(color: Colors.white24, height: 24),
                    Text(
                      '${langNotifier.translate('natural_log')} ln(${_valCtrl.text}): ${_lnValue.toStringAsFixed(6)}',
                      style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
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
                      controller: _valCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: langNotifier.translate('value_x'), border: const OutlineInputBorder()),
                      onChanged: (_) => _calculate(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _baseCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: langNotifier.translate('log_base'), border: const OutlineInputBorder()),
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

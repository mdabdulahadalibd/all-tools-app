import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/tool_categories.dart';
import '../../../../../core/localization/localization_provider.dart';
import '../../../../common/widgets/responsive_container.dart';

class ApGpSeriesScreen extends ConsumerStatefulWidget {
  const ApGpSeriesScreen({super.key});

  @override
  ConsumerState<ApGpSeriesScreen> createState() => _ApGpSeriesScreenState();
}

class _ApGpSeriesScreenState extends ConsumerState<ApGpSeriesScreen> {
  bool _isAp = true;
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
    final langNotifier = ref.watch(languageProvider.notifier);
    final lang = ref.watch(languageProvider);
    final tool = ToolCategories.getToolById('ap_gp_series_calc');

    return Scaffold(
      appBar: AppBar(title: Text(tool.getTitle(lang)), centerTitle: true),
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
                    Text(_isAp ? langNotifier.translate('arithmetic_progression') : langNotifier.translate('geometric_progression'), style: const TextStyle(color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 12),
                    Text('${_nTermsCtrl.text}${langNotifier.translate('th_term')}: ${_nthTerm.toStringAsFixed(2)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.amberAccent)),
                    const SizedBox(height: 6),
                    Text('${langNotifier.translate('sum_of_terms')} (${_nTermsCtrl.text}): ${_sumN.toStringAsFixed(2)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.lightGreenAccent)),
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
                            label: Text(langNotifier.translate('arithmetic_progression')),
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
                            label: Text(langNotifier.translate('geometric_progression')),
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
                      decoration: InputDecoration(labelText: langNotifier.translate('first_term'), border: const OutlineInputBorder()),
                      onChanged: (_) => _calculate(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _diffRatioCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: _isAp ? langNotifier.translate('common_difference') : langNotifier.translate('common_ratio'), border: const OutlineInputBorder()),
                      onChanged: (_) => _calculate(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nTermsCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: langNotifier.translate('number_of_terms'), border: const OutlineInputBorder()),
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

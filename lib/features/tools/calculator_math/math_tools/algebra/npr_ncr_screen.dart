import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/tool_categories.dart';
import '../../../../../core/localization/localization_provider.dart';
import '../../../../common/widgets/responsive_container.dart';

class NprNcrScreen extends ConsumerStatefulWidget {
  const NprNcrScreen({super.key});

  @override
  ConsumerState<NprNcrScreen> createState() => _NprNcrScreenState();
}

class _NprNcrScreenState extends ConsumerState<NprNcrScreen> {
  final TextEditingController _nCtrl = TextEditingController(text: '7');
  final TextEditingController _rCtrl = TextEditingController(text: '3');

  int _nPr = 210;
  int _nCr = 35;

  int _factorial(int n) {
    if (n <= 1) return 1;
    int fact = 1;
    for (int i = 2; i <= n; i++) {
      fact *= i;
    }
    return fact;
  }

  void _calculate() {
    int n = int.tryParse(_nCtrl.text) ?? 0;
    int r = int.tryParse(_rCtrl.text) ?? 0;

    if (n < 0 || r < 0 || r > n) {
      setState(() {
        _nPr = 0;
        _nCr = 0;
      });
      return;
    }

    int nFact = _factorial(n);
    int rFact = _factorial(r);
    int nMinusRFact = _factorial(n - r);

    setState(() {
      _nPr = nFact ~/ nMinusRFact;
      _nCr = nFact ~/ (rFact * nMinusRFact);
    });
  }

  @override
  Widget build(BuildContext context) {
    final langNotifier = ref.watch(languageProvider.notifier);
    final lang = ref.watch(languageProvider);
    final tool = ToolCategories.getToolById('npr_ncr_calc');

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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(langNotifier.translate('permutation_npr'), style: const TextStyle(color: Colors.white70, fontSize: 16)),
                        const SizedBox(height: 8),
                        Text('$_nPr', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.amberAccent)),
                      ],
                    ),
                    Column(
                      children: [
                        Text(langNotifier.translate('combination_ncr'), style: const TextStyle(color: Colors.white70, fontSize: 16)),
                        const SizedBox(height: 8),
                        Text('$_nCr', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.lightGreenAccent)),
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
                child: Column(
                  children: [
                    TextField(
                      controller: _nCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: langNotifier.translate('total_items_n'), border: const OutlineInputBorder()),
                      onChanged: (_) => _calculate(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _rCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: langNotifier.translate('selected_items_r'), border: const OutlineInputBorder()),
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

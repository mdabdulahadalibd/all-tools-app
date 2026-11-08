import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/tool_categories.dart';
import '../../../../core/localization/localization_provider.dart';
import '../../../common/widgets/responsive_container.dart';

class ProfitLossCalculatorScreen extends ConsumerStatefulWidget {
  const ProfitLossCalculatorScreen({super.key});

  @override
  ConsumerState<ProfitLossCalculatorScreen> createState() => _ProfitLossCalculatorScreenState();
}

class _ProfitLossCalculatorScreenState extends ConsumerState<ProfitLossCalculatorScreen> {
  final TextEditingController _costPriceCtrl = TextEditingController(text: '800');
  final TextEditingController _sellingPriceCtrl = TextEditingController(text: '1000');

  double _profitAmount = 200.0;
  double _profitPercent = 25.0;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    double cp = double.tryParse(_costPriceCtrl.text) ?? 0;
    double sp = double.tryParse(_sellingPriceCtrl.text) ?? 0;

    double diff = sp - cp;
    double percent = cp > 0 ? (diff / cp) * 100 : 0;

    setState(() {
      _profitAmount = diff;
      _profitPercent = percent;
    });
  }

  @override
  Widget build(BuildContext context) {
    final langNotifier = ref.watch(languageProvider.notifier);
    final lang = ref.watch(languageProvider);
    final tool = ToolCategories.getToolById('profit_loss_calc');
    bool isProfit = _profitAmount >= 0;

    return Scaffold(
      appBar: AppBar(title: Text(tool.getTitle(lang)), centerTitle: true),
      body: ResponsiveContainer(
        maxWidth: 700,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: isProfit ? Colors.green.shade900 : Colors.red.shade900,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(isProfit ? langNotifier.translate('net_profit') : langNotifier.translate('net_loss'), style: const TextStyle(color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      '৳ ${_profitAmount.abs().toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const Divider(color: Colors.white24, height: 24),
                    Text(
                      'Rate: ${_profitPercent.abs().toStringAsFixed(2)}%',
                      style: const TextStyle(fontSize: 18, color: Colors.amberAccent, fontWeight: FontWeight.bold),
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
                      controller: _costPriceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: langNotifier.translate('cost_price'), border: const OutlineInputBorder()),
                      onChanged: (_) => _calculate(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _sellingPriceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: langNotifier.translate('selling_price'), border: const OutlineInputBorder()),
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
